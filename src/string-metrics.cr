require "./string-metrics/*"

# A module containing a collection of well known string metric algorithms
module StringMetrics
  # Returns the min edit distance between two strings. If the strings are exactly the same it will return 0,
  # but if they differ it will return the minimum number of insertions, deletions, or substitutions to make them exactly the same.
  # ```crystal
  # StringMetrics.levenshtein("Car", "Char") == 1
  # ```
  # More detail can be found [here](https://en.wikipedia.org/wiki/Levenshtein_distance).
  #
  # Ported from [here](https://en.wikibooks.org/wiki/Algorithm_Implementation/Strings/Levenshtein_distance#Python)
  def self.levenshtein(s1 : String, s2 : String) : Int
    return levenshtein(s2, s1) if s1.size < s2.size
    return s1.size if s2.size == 0

    previous_row = (0..s2.size).to_a
    s1_chars = s1.chars
    s2_chars = s2.chars
    # it's expensive to continually recreate an array
    cache = [[0] * (s2.size + 1), [0] * (s2.size + 1)]
    s1_chars.each_with_index do |c1, i|
      current_row = cache[i % 2]
      current_row[0] = i + 1
      s2_chars.each_with_index do |c2, j|
        insertions = previous_row.unsafe_at(j + 1) + 1
        deletions = current_row.unsafe_at(j) + 1
        substitutions = previous_row.unsafe_at(j)
        substitutions += 1 if c1 != c2
        # could have minned a tuple, but this is a bit faster
        min = insertions
        min = deletions if deletions < min
        min = substitutions if substitutions < min
        # main bottleneck is here, memory writes to an already allocated address :/
        current_row[j + 1] = min
      end
      previous_row = current_row
    end
    previous_row.last
  end

  # Returns the number of substitutions that exist between two strings of equal length.
  # Will raise an ArgumentError if both parameters aren't of the same length
  # ```crystal
  # StringMetrics.hamming("Micro", "Macro") == 1
  # ```
  def self.hamming(s1 : String, s2 : String) : Int
    raise ArgumentError.new("input lengths are not equal") if s1.size != s2.size
    (0...s2.size).sum { |i| (s1[i] != s2[i]) ? 1 : 0 }
  end

  # A variation of the Levenshtein distance, this counts transpositions as a single edit.
  # ```crystal
  # StringMetrics.damerau_levenshtein("char", "hcar") == 1
  # ```
  # as opposed to a distance of 2 from levenshtein on it's own
  #
  # Ported from [here](https://github.com/jamesturk/jellyfish/blob/master/jellyfish/_jellyfish.py)
  def self.damerau_levenshtein(s1 : String, s2 : String) : Int
    infinite = s1.size + s2.size

    da = Hash(Char, Int32).new(default_value = 0)

    # distance matrix
    score = (0...s1.size + 2).to_a.map { |i| [0]*(s2.size + 2) }
    score[0][0] = infinite

    (0...s1.size + 1).each do |i|
      score[i + 1][0] = infinite
      score[i + 1][1] = i
    end
    (0...s2.size + 1).each do |i|
      score[0][i + 1] = infinite
      score[1][i + 1] = i
    end

    s1_chars = s1.chars
    s2_chars = s2.chars

    (1..s1.size).each do |i|
      db = 0
      (1..s2.size).each do |j|
        i1 = da[s2_chars[j - 1]]
        j1 = db
        cost = 1
        if s1_chars[i - 1] == s2_chars[j - 1]
          cost = 0
          db = j
        end

        score[i + 1][j + 1] = {
          score[i][j] + cost,
          score[i + 1][j] + 1,
          score[i][j + 1] + 1,
          score[i1][j1] + (i - i1 - 1) + 1 + (j - j1 - 1),
        }.min
      end
      da[s1_chars[i - 1]] = i
    end
    score[s1.size + 1][s2.size + 1]
  end

  # Based off https://rosettacode.org/wiki/Jaro_distance#Python and
  # https://github.com/jamesturk/jellyfish/blob/master/jellyfish/_jellyfish.py
  private def self.reused_jaro_winkler(s1 : String, s2 : String, winkler = true, scaling_factor = 0.1)
    s1_size = s1.size
    s2_size = s2.size
    return 1 if [s1_size, s2_size].all? { |i| i == 0 }
    max_len = {s1_size, s2_size}.max
    match_distance = max_len / 2 - 1

    s1_matches = [false] * s1_size
    s2_matches = [false] * s2_size

    matches = 0
    transpositions = 0
    s1_chars = s1.chars
    s2_chars = s2.chars

    (0...s1_size).each do |i|
      start = {i - match_distance, 0}.max
      ending = {i + match_distance + 1, s2_size}.min

      (start...ending).each do |j|
        next if s2_matches[j]
        next if s1_chars[i] != s2_chars[j]
        s1_matches[i] = true
        s2_matches[j] = true
        matches += 1
        break
      end
    end

    return 0 if matches == 0

    k = 0
    (0...s1_size).each do |i|
      next if !s1_matches[i]

      while !s2_matches[k]
        k += 1
      end

      if s1_chars[i] != s2_chars[k]
        transpositions += 1
      end
      k += 1
    end
    weight = ((matches.fdiv s1_size) + (matches.fdiv s2_size) + ((matches - transpositions.fdiv 2).fdiv matches)).fdiv 3

    if winkler && weight > 0.7 && s1_size > 3 && s2_size > 3
      j = {max_len, 4}.min
      i = 0
      while i < j && s1_chars[i] == s2_chars[i]
        i += 1
      end
      if i > 0
        weight += i * scaling_factor * (1.0 - weight)
      end
    end
    weight
  end

  # A measure of similarity between two strings based on matching characters.
  # Returns 0 if there is no similarity while 1 is an exact match
  # ```crystal
  # StringMetrics.jaro("MARTHA", "MARHTA").round(2) == 0.94
  # ```
  def self.jaro(s1 : String, s2 : String)
    reused_jaro_winkler(s1, s2, false)
  end

  # Similar to regular Jaro, but gives a higher score for matching from the beginning
  # of the string. Only change the scaling factor if you're intimate with the algorithm.
  # ```crystal
  # StringMetrics.jaro_winkler("MARTHA", "MARHTA").round(2) == 0.96
  # ```
  def self.jaro_winkler(s1 : String, s2 : String, scaling_factor = 0.1)
    reused_jaro_winkler(s1, s2, scaling_factor: scaling_factor)
  end
end

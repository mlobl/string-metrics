require "./string-metrics/*"

# TODO: Write documentation for `String::Metrics`
module StringMetrics

  # Gets the min edit distance between two strings.
  # See https://en.wikipedia.org/wiki/Levenshtein_distance
  # Ported from https://en.wikibooks.org/wiki/Algorithm_Implementation/Strings/Levenshtein_distance#Python
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
        substitutions +=  1 if c1 != c2
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

  def self.hamming(s1 : String, s2 : String) : Int
    raise ArgumentError.new("input lengths are not equal") if s1.size != s2.size
    (0...s2.size).sum { |i| (s1[i] != s2[i])? 1 : 0 }
  end

  # A variation of the Levenshtein distance, this counts transpositions as a single edit.
  # ```damerau_levenshtein("char", "hcar") == 1``` as opposed to a distance of 2 from levenshtein
  # on it's own
  # Ported from https://github.com/jamesturk/jellyfish/blob/master/jellyfish/_jellyfish.py
  def self.damerau_levenshtein(s1 : String, s2 : String) : Int
    infinite = s1.size + s2.size

    da = Hash(Char, Int32).new(default_value=0)

    # distance matrix
    score = (0...s1.size + 2).to_a.map {|i| [0]*(s2.size + 2)}
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
        i1 = da[s2_chars[j-1]]
        j1 = db
        cost = 1
        if s1_chars[i - 1] == s2_chars[j - 1]
          cost = 0
          db = j
        end

        score[i + 1][j + 1] = {
          score[i][j] + cost,
          score[i+1][j] + 1,
          score[i][j+1] + 1,
          score[i1][j1] + (i - i1 - 1) + 1 + (j - j1 - 1)
        }.min
      end
      da[s1_chars[i - 1]] = i
    end
    score[s1.size + 1][s2.size + 1]
  end

end

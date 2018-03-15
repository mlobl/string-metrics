require "../src/string-metrics"

# A stress test to profile with
a = "n information theory, linguistics and computer science, the Levenshtein distance is a string metric for measuring the difference between two sequences. Informally, the Levenshtein distance between two words is the minimum number of single-character edits (insertions, deletions or substitutions) required to change one word into the other. It is named after the Soviet mathematician Vladimir Levenshtein, who considered this distance in 1965"
b = "The Levenshtein distance can also be computed between two longer strings, but the cost to compute it, which is roughly proportional to the product of the two string lengths, makes this impractical. Thus, when used to aid in fuzzy string searching in applications such as record linkage, the compared strings are usually short to help improve speed of comparisons."
start_time = Time.now()
result = StringMetrics.levenshtein(a*50, b*50)
timing = (Time.now() - start_time)
puts "Distance was #{result} and took #{timing}"

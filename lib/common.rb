# from http://blog.slashpoundbang.com/post/12938588984/remove-all-accents-and-diacritics-from-string-in-ruby
# Since we only do lookups on lowercase strings, we only need to do the
# conversion for lowercase characters
def remove_accented_characters(string)
  string.tr(
    "‘àáâãäåāăąçćĉċčðďđèéêëēĕėęěĝğġģĥħìíîïĩīĭįıĵķĸĺļľŀłñńņňŉŋòóôõöøōŏőŕŗřśŝşšſţťŧùúûüũūŭůűųŵýÿŷźżž",
    "'aaaaaaaaacccccdddeeeeeeeeegggghhiiiiiiiiijkklllllnnnnnnooooooooorrrssssstttuuuuuuuuuuwyyyzzz"
  )
end

## Nim Emoji Maintenance Script: Syncs Emoji with The Unicode Standard.
# http:github.com/nim-lang/Nim/blob/master/lib/packages/docutils/rst.nim#L73
import os, httpclient, json, strutils

# EmojiOne project pulls from Unicode and serves a JSON, with ":this:" notation.
const
  url = "https://raw.githubusercontent.com/joypixels/emojione/master/emoji.json"
  emojiraw = "emoji-raw.json"
  output = "emoji-verified.json" # Not a JSON, but for editor syntax highlight
  line = "    \"$1\": \"icon_$2\", # v$3  \\u$4\n"
  blacklist = [
    ":arrow:",
  ] # Add ":smiley:" here to intentionally remove them for whatever reason.

if not existsFile(emojiraw):
  writeFile(emojiraw, newHttpClient().getContent(url).parseJson.pretty)

let jotason = readFile(emojiraw).parseJson

var emojis = "{\n"
for element in jotason.pairs:
  var
    name = element.val["code_points"]["base"].str.normalize
    shortname = element.val["shortname"].str.replace("-", "_")
    semver = element.val["unicode_version"]
  if name.len == 5 and shortname.len > 5 and not contains(shortname, "tone"):
    if shortname notin blacklist:  # Remove Blacklisted and Skin Tones, etc.
      emojis &= line.format(shortname, shortname.replace(":", ""), semver, name)
emojis &= "}\n"

writeFile(output, emojis)

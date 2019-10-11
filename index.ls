require! <[
  crypto
  path
]>
require! {
  \js-yaml : yaml
  \fs-extra : fs
}


日期 = '日期'

FILE_LI = []

trim-end = (txt)~>
  li = []
  for i in txt.replace(/\r\n/g,"\n").replace(/\r/g,"\n").split("\n")
    li.push i.trimEnd!
  li.join '\n'


module.exports = {
  end : (dir)!~>
    FILE_LI.sort ([a],[b])~>
      if a < 0 and b > 0
        return -1
      if a > 0 and b < 0
        return 1
      b - a

    li = []
    for [time, hash, filepath] in FILE_LI
      li.push [
        time.toString(36)
        hash.digest('base64').slice(0,-1)
        filepath.slice(3,-3)
      ].join ' '
    await fs.writeFile path.join(dir, 'li/index.li'), li.join('\n')

  file : (buf)~>
    filepath = buf.path
    buf = buf.toString(\utf-8)
    buf = trim-end buf
    pos = buf.indexOf("\n------\n")
    if pos + 1
      ptxt = buf.slice(0,pos)
      atxt = buf.slice(pos)
      spos = ptxt.lastIndexOf('\n---\n')

      if spos + 1
        spos = spos+5
        head = ptxt.slice(0, spos)
        meta = ptxt.slice(spos)
      else
        head = ""
        meta = ptxt

      meta = yaml.safeLoad meta
      if not (日期 of meta)
        date = (await fs.stat(filepath)).ctime
      else
        date = meta[日期]
        delete meta[日期]

      if Number.isInteger(date)
        date-str = date
      else
        date-str = date.toISOString().replace('T',' ').split(".")[0]
        date = parseInt(date/1000)

      li = []
      for k,v of meta
        li.push "#k : #v"
      li.sort()
      li.push "#{日期} : "+date-str

      meta = li.join '\n'
      ptxt = head+'\n'+meta+"\n"
      buf = Buffer.from(ptxt+atxt)
      line = [
        date
        crypto.createHash('sha256').update(buf)
        filepath
      ]
      FILE_LI.push(line)
      return buf
    return buf
}

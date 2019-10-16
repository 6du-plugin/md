require! <[
  crypto
  path
]>
require! {
  \js-yaml : yaml
  \fs-extra : fs
}

TIMEZONE = new Date().getTimezoneOffset()*60

日期 = '日期'

FILE_LI = []

trim-end = (txt)~>
  li = []
  for i in txt.replace(/\r\n/g,"\n").replace(/\r/g,"\n").split("\n")
    i = i.trimEnd!
    if i or li.length
      li.push i
  while li.length
    if li[li.length-1]
      break
    else
      li.pop()
  li.join('\n')+"\n"

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
      # li.push [
      #   time.toString(36)
      # ].join ' '

      name = filepath.slice(0,-3) + "\n"

      len = name.length
      buf = Buffer.allocUnsafe(6+32+len)
      buf.writeIntBE time, 0, 6
      hash.digest!.copy buf, 6
      buf.write name, 38, len
      li.push buf

    await fs.outputFile path.join(dir, 'li/index.js'), Buffer.concat(li)

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
        head = []
        for i in ptxt.split("\n")
          if i.trim().startsWith "#"
            head.push(i)
        head = head.join('\n')
        if head
          head += "\n"
        meta = ptxt

      meta = (yaml.safeLoad meta) or {}
      if not (日期 of meta)
        date = (await fs.stat(filepath)).ctime
        date = new Date(date - TIMEZONE*1000)
      else
        date = meta[日期]
        delete meta[日期]

      if Number.isInteger(date)
        date-str = date
      else
        date-str = date.toISOString().replace('T',' ').split(".")[0]
        date = parseInt(date/1000+TIMEZONE)

      li = []
      for k,v of meta
        li.push "#k : #v"
      li.sort()
      li.push "#{日期} : "+date-str

      meta = li.join '\n'
      ptxt = head+'\n'+meta+"\n"
      buf = Buffer.from(ptxt+atxt+"\n")

      h1 = false
      for i in ptxt.split("\n")
        if i.startsWith "#"
          h1 = true
          break
      if h1
        line = [
          date
          crypto.createHash('sha256').update(buf)
          filepath
        ]
        FILE_LI.push(line)
      return buf
    return buf
}

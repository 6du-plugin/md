require! <[
  crypto
]>
require! {
  \js-yaml : yaml
  \fs-extra : fs
}


日期 = '日期'

FILE_LI = []

module.exports = {
  end : (dir)!~>
    FILE_LI.sort()
    console.log dir, FILE_LI
  file : (buf)~>
    filepath = buf.path
    buf = buf.toString(\utf-8)
    buf = buf.replace(/\r\n/g,"\n").replace(/\r/g,"\n")
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
      date = date.toISOString().replace('T',' ').split(".")[0]

      li = []
      for k,v of meta
        li.push "#k : #v"
      li.sort()
      li.push "#{日期} : "+date

      meta = li.join '\n'
      ptxt = head+'\n'+meta+"\n"
      buf = Buffer.from(ptxt+atxt)
      line = [
        parseInt new Date(date)/1000
        crypto.createHash('sha256').update(buf).digest('base64').slice(0,-1)
        filepath
      ]
      FILE_LI.push(line)
      return buf
    return buf
}

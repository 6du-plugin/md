require! {
  \js-yaml : yaml
  \fs-extra : fs
}

日期 = '日期'

module.exports = (buf)~>
  filepath = buf.path
  buf = buf.toString(\utf-8)
  buf = buf.replace(/\r\n/g,"\n").replace(/\r/g,"\n")
  pos = buf.indexOf("\n------\n")
  if pos + 1
    console.log filepath
    ptxt = buf.slice(0,pos)
    atxt = buf.slice(pos)
    spos = ptxt.lastIndexOf('\n---\n')

    if spos + 1
      head = ptxt.slice(0, spos)
      meta = ptxt.slice(spos+5)
      meta = yaml.safeLoad meta
      if not (日期 of meta)
        console.log meta
        console.log await fs.stat(filepath)
  buf

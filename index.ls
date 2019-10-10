require! {
  \js-yaml : yaml
}

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
      console.log meta, yaml.safeLoad meta
  buf

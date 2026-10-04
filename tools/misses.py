# for each halo turn with >20k uncached input: what preceded it (entry types, gap since previous entry, model change, compaction)
import json,glob,os
root=os.path.expanduser("~/.pi/agent/sessions")
for f in sorted(glob.glob(root+"/**/*.jsonl",recursive=True)):
    ents=[]
    for l in open(f,errors="ignore"):
        try: ents.append(json.loads(l))
        except: pass
    prev_ts=None; recent=[]
    for idx,j in enumerate(ents):
        m=j.get("message") if isinstance(j.get("message"),dict) else {}
        ts=m.get("timestamp") if isinstance(m.get("timestamp"),(int,float)) else None
        kind=j.get("type"); 
        if m.get("role")=="assistant" and m.get("provider")=="halo" and isinstance(m.get("usage"),dict):
            u=m["usage"]
            if (u.get("input") or 0)>20000:
                gap=(ts-prev_ts)/1000 if ts and prev_ts else None
                print(os.path.basename(f)[:19],"entry",idx,"uncached",u["input"],"cached",u.get("cacheRead"),"gap_s",None if gap is None else round(gap),"preceding types",recent[-4:])
        recent.append(kind if kind!="message" else "msg:"+str(m.get("role")) + ("/"+str(m.get("provider")) if m.get("provider") else ""))
        if ts: prev_ts=ts

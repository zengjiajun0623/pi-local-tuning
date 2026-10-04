# numeric-only tail analysis of halo turns: output tails, stop reasons, uncached prefill, wall time per turn
import json,glob,os,collections,statistics as st
root=os.path.expanduser("~/.pi/agent/sessions")
outs=[];reas=[];unc=[];stop=collections.Counter();walls=[];ctx=[];big_unc=0;rows=[]
for f in glob.glob(root+"/**/*.jsonl",recursive=True):
    prev=None
    for l in open(f,errors="ignore"):
        try: j=json.loads(l)
        except: continue
        m=j.get("message")
        if not isinstance(m,dict): continue
        ts=m.get("timestamp")
        if m.get("role")=="assistant" and m.get("provider")=="halo" and isinstance(m.get("usage"),dict):
            u=m["usage"];o=u.get("output",0) or 0;i=u.get("input",0) or 0;c=u.get("cacheRead",0) or 0
            outs.append(o);reas.append(u.get("reasoning",0) or 0);unc.append(i);ctx.append(i+c)
            stop[m.get("stopReason")]+=1
            if i>20000: big_unc+=1
            if prev and ts and isinstance(ts,(int,float)) and isinstance(prev,(int,float)):
                w=(ts-prev)/1000
                if 0<w<3600: walls.append(w); rows.append((w,o,i,i+c))
        if isinstance(ts,(int,float)): prev=ts
def pct(a,p): a=sorted(a); return a[min(len(a)-1,int(p*len(a)))]
print("halo turns",len(outs))
print("output p50/p90/p99/max",pct(outs,.5),pct(outs,.9),pct(outs,.99),max(outs))
print("reasoning p50/p90/p99/max",pct(reas,.5),pct(reas,.9),pct(reas,.99),max(reas), " turns reasoning>=8000:",sum(r>=8000 for r in reas)," >=15000:",sum(r>=15000 for r in reas))
print("stopReasons",dict(stop))
print("uncached input p50/p90/p99/max",pct(unc,.5),pct(unc,.9),pct(unc,.99),max(unc)," turns >20k uncached:",big_unc," sum uncached in those:",sum(x for x in unc if x>20000))
print("context p50/p90/max",pct(ctx,.5),pct(ctx,.9),max(ctx))
if walls:
    print("wall s/turn p50/p90/p99/max %.1f %.1f %.1f %.1f total_h %.2f"%(pct(walls,.5),pct(walls,.9),pct(walls,.99),max(walls),sum(walls)/3600))
    # share of wall time from slowest 10% of turns
    s=sorted(walls); print("share of wall time in slowest 10%% turns: %.0f%%"%(100*sum(s[int(.9*len(s)):])/sum(s)))
    # implied decode speed by context bucket (wall includes prefill+tool time, rough)
    for lo,hi in((0,32e3),(32e3,64e3),(64e3,128e3),(128e3,300e3)):
        r=[(w,o) for w,o,i,c in rows if lo<=c<hi and o>200 and i<4000]
        if r: print(f" ctx {int(lo/1e3)}-{int(hi/1e3)}k: n={len(r)} median out/wall tok/s={st.median(o/w for w,o in r):.1f}")

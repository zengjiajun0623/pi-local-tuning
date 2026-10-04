import json,glob,collections,os,statistics as st
root=os.path.expanduser("~/.pi/agent/sessions")
S=collections.defaultdict(lambda: collections.defaultdict(float))
lv=collections.defaultdict(lambda: collections.defaultdict(lambda:[0,0,0]))  # (provider,level)->[n,out,reason]
outs=collections.defaultdict(list)
tool=collections.defaultdict(lambda:[0,0])  # toolName->[count,chars]
files=0
for f in glob.glob(root+"/**/*.jsonl",recursive=True):
    files+=1
    for l in open(f,errors="ignore"):
        try: j=json.loads(l)
        except: continue
        m=j.get("message")
        if not isinstance(m,dict): continue
        r=m.get("role")
        if r=="assistant" and isinstance(m.get("usage"),dict):
            p=m.get("provider") or "?"; u=m["usage"]
            s=S[p]; s["turns"]+=1
            for k in("input","output","reasoning","cacheRead"): s[k]+=u.get(k,0) or 0
            c=m.get("content") or []
            s["toolcalls"]+=sum(1 for b in c if isinstance(b,dict) and b.get("type")=="toolCall")
            s["thinkchars"]+=sum(len(b.get("thinking","")) for b in c if isinstance(b,dict) and b.get("type")=="thinking")
            s["textchars"]+=sum(len(b.get("text","")) for b in c if isinstance(b,dict) and b.get("type")=="text")
            s["tcchars"]+=sum(len(json.dumps(b.get("arguments",""))) for b in c if isinstance(b,dict) and b.get("type")=="toolCall")
            x=lv[p][m.get("thinkingLevel")]; x[0]+=1; x[1]+=u.get("output",0) or 0; x[2]+=u.get("reasoning",0) or 0
            outs[p].append(u.get("output",0) or 0)
            if (u.get("output",0) or 0)==(u.get("reasoning",0) or 0) and (u.get("output",0) or 0)>0: s["pure_think_turns"]+=1
        elif r=="toolResult":
            n=m.get("toolName") or "?"
            ch=sum(len(b.get("text","")) for b in (m.get("content") or []) if isinstance(b,dict))
            tool[n][0]+=1; tool[n][1]+=ch
print("files",files)
for p,s in S.items():
    t=s["turns"]; o=s["output"]
    print(f"\n[{p}] turns={int(t)} input={int(s['input'])} cacheRead={int(s['cacheRead'])} output={int(o)} reasoning={int(s['reasoning'])} ({100*s['reasoning']/max(o,1):.0f}% of output)")
    print(f"  avg output/turn={o/t:.0f} median={st.median(outs[p]):.0f} p90={sorted(outs[p])[int(.9*len(outs[p]))]} ; toolcalls/turn={s['toolcalls']/t:.2f} ; turns that are pure thinking+toolcall(no text)={int(s['pure_think_turns'])}")
    print(f"  chars: thinking={int(s['thinkchars'])} visible_text={int(s['textchars'])} toolcall_args={int(s['tcchars'])}")
    for k,v in sorted(lv[p].items(),key=lambda kv:-kv[1][0]): print(f"  thinkingLevel={k}: turns={v[0]} avg_out={v[1]/v[0]:.0f} avg_reasoning={v[2]/v[0]:.0f}")
print("\ntool results (count, avg chars):")
for n,(c,ch) in sorted(tool.items(),key=lambda kv:-kv[1][1])[:8]: print(f"  {n}: {c} avg {ch/c:.0f} total {ch}")

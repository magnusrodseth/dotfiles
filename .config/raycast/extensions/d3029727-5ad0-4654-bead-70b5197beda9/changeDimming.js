var yn=Object.create;var M=Object.defineProperty;var Sn=Object.getOwnPropertyDescriptor;var gn=Object.getOwnPropertyNames;var xn=Object.getPrototypeOf,bn=Object.prototype.hasOwnProperty;var Ce=e=>M(e,"__esModule",{value:!0});var c=(e,t)=>()=>(t||e((t={exports:{}}).exports,t),t.exports),wn=(e,t)=>{Ce(e);for(var r in t)M(e,r,{get:t[r],enumerable:!0})},vn=(e,t,r)=>{if(t&&typeof t=="object"||typeof t=="function")for(let n of gn(t))!bn.call(e,n)&&n!=="default"&&M(e,n,{get:()=>t[n],enumerable:!(r=Sn(t,n))||r.enumerable});return e},U=e=>vn(Ce(M(e!=null?yn(xn(e)):{},"default",e&&e.__esModule&&"default"in e?{get:()=>e.default,enumerable:!0}:{value:e,enumerable:!0})),e);var Re=c((bs,Oe)=>{Oe.exports=Ae;Ae.sync=En;var Pe=require("fs");function In(e,t){var r=t.pathExt!==void 0?t.pathExt:process.env.PATHEXT;if(!r||(r=r.split(";"),r.indexOf("")!==-1))return!0;for(var n=0;n<r.length;n++){var s=r[n].toLowerCase();if(s&&e.substr(-s.length).toLowerCase()===s)return!0}return!1}function Ge(e,t,r){return!e.isSymbolicLink()&&!e.isFile()?!1:In(t,r)}function Ae(e,t,r){Pe.stat(e,function(n,s){r(n,n?!1:Ge(s,e,t))})}function En(e,t){return Ge(Pe.statSync(e),e,t)}});var _e=c((ws,$e)=>{$e.exports=Ne;Ne.sync=Tn;var qe=require("fs");function Ne(e,t,r){qe.stat(e,function(n,s){r(n,n?!1:ke(s,t))})}function Tn(e,t){return ke(qe.statSync(e),t)}function ke(e,t){return e.isFile()&&Cn(e,t)}function Cn(e,t){var r=e.mode,n=e.uid,s=e.gid,i=t.uid!==void 0?t.uid:process.getuid&&process.getuid(),o=t.gid!==void 0?t.gid:process.getgid&&process.getgid(),a=parseInt("100",8),u=parseInt("010",8),l=parseInt("001",8),p=a|u,y=r&l||r&u&&s===o||r&a&&n===i||r&p&&i===0;return y}});var Le=c((Is,je)=>{var vs=require("fs"),D;process.platform==="win32"||global.TESTING_WINDOWS?D=Re():D=_e();je.exports=ee;ee.sync=Pn;function ee(e,t,r){if(typeof t=="function"&&(r=t,t={}),!r){if(typeof Promise!="function")throw new TypeError("callback not provided");return new Promise(function(n,s){ee(e,t||{},function(i,o){i?s(i):n(o)})})}D(e,t||{},function(n,s){n&&(n.code==="EACCES"||t&&t.ignoreErrors)&&(n=null,s=!1),r(n,s)})}function Pn(e,t){try{return D.sync(e,t||{})}catch(r){if(t&&t.ignoreErrors||r.code==="EACCES")return!1;throw r}}});var Xe=c((Es,He)=>{var T=process.platform==="win32"||process.env.OSTYPE==="cygwin"||process.env.OSTYPE==="msys",Be=require("path"),Gn=T?";":":",Me=Le(),Ue=e=>Object.assign(new Error(`not found: ${e}`),{code:"ENOENT"}),De=(e,t)=>{let r=t.colon||Gn,n=e.match(/\//)||T&&e.match(/\\/)?[""]:[...T?[process.cwd()]:[],...(t.path||process.env.PATH||"").split(r)],s=T?t.pathExt||process.env.PATHEXT||".EXE;.CMD;.BAT;.COM":"",i=T?s.split(r):[""];return T&&e.indexOf(".")!==-1&&i[0]!==""&&i.unshift(""),{pathEnv:n,pathExt:i,pathExtExe:s}},Fe=(e,t,r)=>{typeof t=="function"&&(r=t,t={}),t||(t={});let{pathEnv:n,pathExt:s,pathExtExe:i}=De(e,t),o=[],a=l=>new Promise((p,y)=>{if(l===n.length)return t.all&&o.length?p(o):y(Ue(e));let h=n[l],S=/^".*"$/.test(h)?h.slice(1,-1):h,g=Be.join(S,e),x=!S&&/^\.[\\\/]/.test(e)?e.slice(0,2)+g:g;p(u(x,l,0))}),u=(l,p,y)=>new Promise((h,S)=>{if(y===s.length)return h(a(p+1));let g=s[y];Me(l+g,{pathExt:i},(x,E)=>{if(!x&&E)if(t.all)o.push(l+g);else return h(l+g);return h(u(l,p,y+1))})});return r?a(0).then(l=>r(null,l),r):a(0)},An=(e,t)=>{t=t||{};let{pathEnv:r,pathExt:n,pathExtExe:s}=De(e,t),i=[];for(let o=0;o<r.length;o++){let a=r[o],u=/^".*"$/.test(a)?a.slice(1,-1):a,l=Be.join(u,e),p=!u&&/^\.[\\\/]/.test(e)?e.slice(0,2)+l:l;for(let y=0;y<n.length;y++){let h=p+n[y];try{if(Me.sync(h,{pathExt:s}))if(t.all)i.push(h);else return h}catch{}}}if(t.all&&i.length)return i;if(t.nothrow)return null;throw Ue(e)};He.exports=Fe;Fe.sync=An});var ne=c((Ts,te)=>{"use strict";var ze=(e={})=>{let t=e.env||process.env;return(e.platform||process.platform)!=="win32"?"PATH":Object.keys(t).reverse().find(n=>n.toUpperCase()==="PATH")||"Path"};te.exports=ze;te.exports.default=ze});var Ye=c((Cs,We)=>{"use strict";var Ke=require("path"),On=Xe(),Rn=ne();function Ve(e,t){let r=e.options.env||process.env,n=process.cwd(),s=e.options.cwd!=null,i=s&&process.chdir!==void 0&&!process.chdir.disabled;if(i)try{process.chdir(e.options.cwd)}catch{}let o;try{o=On.sync(e.command,{path:r[Rn({env:r})],pathExt:t?Ke.delimiter:void 0})}catch{}finally{i&&process.chdir(n)}return o&&(o=Ke.resolve(s?e.options.cwd:"",o)),o}function qn(e){return Ve(e)||Ve(e,!0)}We.exports=qn});var Qe=c((Ps,se)=>{"use strict";var re=/([()\][%!^"`<>&|;, *?])/g;function Nn(e){return e=e.replace(re,"^$1"),e}function kn(e,t){return e=`${e}`,e=e.replace(/(\\*)"/g,'$1$1\\"'),e=e.replace(/(\\*)$/,"$1$1"),e=`"${e}"`,e=e.replace(re,"^$1"),t&&(e=e.replace(re,"^$1")),e}se.exports.command=Nn;se.exports.argument=kn});var Je=c((Gs,Ze)=>{"use strict";Ze.exports=/^#!(.*)/});var tt=c((As,et)=>{"use strict";var $n=Je();et.exports=(e="")=>{let t=e.match($n);if(!t)return null;let[r,n]=t[0].replace(/#! ?/,"").split(" "),s=r.split("/").pop();return s==="env"?n:n?`${s} ${n}`:s}});var rt=c((Os,nt)=>{"use strict";var ie=require("fs"),_n=tt();function jn(e){let t=150,r=Buffer.alloc(t),n;try{n=ie.openSync(e,"r"),ie.readSync(n,r,0,t,0),ie.closeSync(n)}catch{}return _n(r.toString())}nt.exports=jn});var at=c((Rs,ot)=>{"use strict";var Ln=require("path"),st=Ye(),it=Qe(),Bn=rt(),Mn=process.platform==="win32",Un=/\.(?:com|exe)$/i,Dn=/node_modules[\\/].bin[\\/][^\\/]+\.cmd$/i;function Fn(e){e.file=st(e);let t=e.file&&Bn(e.file);return t?(e.args.unshift(e.file),e.command=t,st(e)):e.file}function Hn(e){if(!Mn)return e;let t=Fn(e),r=!Un.test(t);if(e.options.forceShell||r){let n=Dn.test(t);e.command=Ln.normalize(e.command),e.command=it.command(e.command),e.args=e.args.map(i=>it.argument(i,n));let s=[e.command].concat(e.args).join(" ");e.args=["/d","/s","/c",`"${s}"`],e.command=process.env.comspec||"cmd.exe",e.options.windowsVerbatimArguments=!0}return e}function Xn(e,t,r){t&&!Array.isArray(t)&&(r=t,t=null),t=t?t.slice(0):[],r=Object.assign({},r);let n={command:e,args:t,options:r,file:void 0,original:{command:e,args:t}};return r.shell?n:Hn(n)}ot.exports=Xn});var lt=c((qs,ut)=>{"use strict";var oe=process.platform==="win32";function ae(e,t){return Object.assign(new Error(`${t} ${e.command} ENOENT`),{code:"ENOENT",errno:"ENOENT",syscall:`${t} ${e.command}`,path:e.command,spawnargs:e.args})}function zn(e,t){if(!oe)return;let r=e.emit;e.emit=function(n,s){if(n==="exit"){let i=ct(s,t,"spawn");if(i)return r.call(e,"error",i)}return r.apply(e,arguments)}}function ct(e,t){return oe&&e===1&&!t.file?ae(t.original,"spawn"):null}function Kn(e,t){return oe&&e===1&&!t.file?ae(t.original,"spawnSync"):null}ut.exports={hookChildProcess:zn,verifyENOENT:ct,verifyENOENTSync:Kn,notFoundError:ae}});var pt=c((Ns,C)=>{"use strict";var dt=require("child_process"),ce=at(),ue=lt();function ft(e,t,r){let n=ce(e,t,r),s=dt.spawn(n.command,n.args,n.options);return ue.hookChildProcess(s,n),s}function Vn(e,t,r){let n=ce(e,t,r),s=dt.spawnSync(n.command,n.args,n.options);return s.error=s.error||ue.verifyENOENTSync(s.status,n),s}C.exports=ft;C.exports.spawn=ft;C.exports.sync=Vn;C.exports._parse=ce;C.exports._enoent=ue});var ht=c((ks,mt)=>{"use strict";mt.exports=e=>{let t=typeof e=="string"?`
`:`
`.charCodeAt(),r=typeof e=="string"?"\r":"\r".charCodeAt();return e[e.length-1]===t&&(e=e.slice(0,e.length-1)),e[e.length-1]===r&&(e=e.slice(0,e.length-1)),e}});var gt=c(($s,k)=>{"use strict";var N=require("path"),yt=ne(),St=e=>{e={cwd:process.cwd(),path:process.env[yt()],execPath:process.execPath,...e};let t,r=N.resolve(e.cwd),n=[];for(;t!==r;)n.push(N.join(r,"node_modules/.bin")),t=r,r=N.resolve(r,"..");let s=N.resolve(e.cwd,e.execPath,"..");return n.push(s),n.concat(e.path).join(N.delimiter)};k.exports=St;k.exports.default=St;k.exports.env=e=>{e={env:process.env,...e};let t={...e.env},r=yt({env:t});return e.path=t[r],t[r]=k.exports(e),t}});var bt=c((_s,le)=>{"use strict";var xt=(e,t)=>{for(let r of Reflect.ownKeys(t))Object.defineProperty(e,r,Object.getOwnPropertyDescriptor(t,r));return e};le.exports=xt;le.exports.default=xt});var vt=c((js,H)=>{"use strict";var Wn=bt(),F=new WeakMap,wt=(e,t={})=>{if(typeof e!="function")throw new TypeError("Expected a function");let r,n=0,s=e.displayName||e.name||"<anonymous>",i=function(...o){if(F.set(i,++n),n===1)r=e.apply(this,o),e=null;else if(t.throw===!0)throw new Error(`Function \`${s}\` can only be called once`);return r};return Wn(i,e),F.set(i,n),i};H.exports=wt;H.exports.default=wt;H.exports.callCount=e=>{if(!F.has(e))throw new Error(`The given function \`${e.name}\` is not wrapped by the \`onetime\` package`);return F.get(e)}});var It=c(X=>{"use strict";Object.defineProperty(X,"__esModule",{value:!0});X.SIGNALS=void 0;var Yn=[{name:"SIGHUP",number:1,action:"terminate",description:"Terminal closed",standard:"posix"},{name:"SIGINT",number:2,action:"terminate",description:"User interruption with CTRL-C",standard:"ansi"},{name:"SIGQUIT",number:3,action:"core",description:"User interruption with CTRL-\\",standard:"posix"},{name:"SIGILL",number:4,action:"core",description:"Invalid machine instruction",standard:"ansi"},{name:"SIGTRAP",number:5,action:"core",description:"Debugger breakpoint",standard:"posix"},{name:"SIGABRT",number:6,action:"core",description:"Aborted",standard:"ansi"},{name:"SIGIOT",number:6,action:"core",description:"Aborted",standard:"bsd"},{name:"SIGBUS",number:7,action:"core",description:"Bus error due to misaligned, non-existing address or paging error",standard:"bsd"},{name:"SIGEMT",number:7,action:"terminate",description:"Command should be emulated but is not implemented",standard:"other"},{name:"SIGFPE",number:8,action:"core",description:"Floating point arithmetic error",standard:"ansi"},{name:"SIGKILL",number:9,action:"terminate",description:"Forced termination",standard:"posix",forced:!0},{name:"SIGUSR1",number:10,action:"terminate",description:"Application-specific signal",standard:"posix"},{name:"SIGSEGV",number:11,action:"core",description:"Segmentation fault",standard:"ansi"},{name:"SIGUSR2",number:12,action:"terminate",description:"Application-specific signal",standard:"posix"},{name:"SIGPIPE",number:13,action:"terminate",description:"Broken pipe or socket",standard:"posix"},{name:"SIGALRM",number:14,action:"terminate",description:"Timeout or timer",standard:"posix"},{name:"SIGTERM",number:15,action:"terminate",description:"Termination",standard:"ansi"},{name:"SIGSTKFLT",number:16,action:"terminate",description:"Stack is empty or overflowed",standard:"other"},{name:"SIGCHLD",number:17,action:"ignore",description:"Child process terminated, paused or unpaused",standard:"posix"},{name:"SIGCLD",number:17,action:"ignore",description:"Child process terminated, paused or unpaused",standard:"other"},{name:"SIGCONT",number:18,action:"unpause",description:"Unpaused",standard:"posix",forced:!0},{name:"SIGSTOP",number:19,action:"pause",description:"Paused",standard:"posix",forced:!0},{name:"SIGTSTP",number:20,action:"pause",description:'Paused using CTRL-Z or "suspend"',standard:"posix"},{name:"SIGTTIN",number:21,action:"pause",description:"Background process cannot read terminal input",standard:"posix"},{name:"SIGBREAK",number:21,action:"terminate",description:"User interruption with CTRL-BREAK",standard:"other"},{name:"SIGTTOU",number:22,action:"pause",description:"Background process cannot write to terminal output",standard:"posix"},{name:"SIGURG",number:23,action:"ignore",description:"Socket received out-of-band data",standard:"bsd"},{name:"SIGXCPU",number:24,action:"core",description:"Process timed out",standard:"bsd"},{name:"SIGXFSZ",number:25,action:"core",description:"File too big",standard:"bsd"},{name:"SIGVTALRM",number:26,action:"terminate",description:"Timeout or timer",standard:"bsd"},{name:"SIGPROF",number:27,action:"terminate",description:"Timeout or timer",standard:"bsd"},{name:"SIGWINCH",number:28,action:"ignore",description:"Terminal window size changed",standard:"bsd"},{name:"SIGIO",number:29,action:"terminate",description:"I/O is available",standard:"other"},{name:"SIGPOLL",number:29,action:"terminate",description:"Watched event",standard:"other"},{name:"SIGINFO",number:29,action:"ignore",description:"Request for process information",standard:"other"},{name:"SIGPWR",number:30,action:"terminate",description:"Device running out of power",standard:"systemv"},{name:"SIGSYS",number:31,action:"core",description:"Invalid system call",standard:"other"},{name:"SIGUNUSED",number:31,action:"terminate",description:"Invalid system call",standard:"other"}];X.SIGNALS=Yn});var de=c(P=>{"use strict";Object.defineProperty(P,"__esModule",{value:!0});P.SIGRTMAX=P.getRealtimeSignals=void 0;var Qn=function(){let e=Tt-Et+1;return Array.from({length:e},Zn)};P.getRealtimeSignals=Qn;var Zn=function(e,t){return{name:`SIGRT${t+1}`,number:Et+t,action:"terminate",description:"Application-specific signal (realtime)",standard:"posix"}},Et=34,Tt=64;P.SIGRTMAX=Tt});var Ct=c(z=>{"use strict";Object.defineProperty(z,"__esModule",{value:!0});z.getSignals=void 0;var Jn=require("os"),er=It(),tr=de(),nr=function(){let e=(0,tr.getRealtimeSignals)();return[...er.SIGNALS,...e].map(rr)};z.getSignals=nr;var rr=function({name:e,number:t,description:r,action:n,forced:s=!1,standard:i}){let{signals:{[e]:o}}=Jn.constants,a=o!==void 0;return{name:e,number:a?o:t,description:r,supported:a,action:n,forced:s,standard:i}}});var Gt=c(G=>{"use strict";Object.defineProperty(G,"__esModule",{value:!0});G.signalsByNumber=G.signalsByName=void 0;var sr=require("os"),Pt=Ct(),ir=de(),or=function(){return(0,Pt.getSignals)().reduce(ar,{})},ar=function(e,{name:t,number:r,description:n,supported:s,action:i,forced:o,standard:a}){return{...e,[t]:{name:t,number:r,description:n,supported:s,action:i,forced:o,standard:a}}},cr=or();G.signalsByName=cr;var ur=function(){let e=(0,Pt.getSignals)(),t=ir.SIGRTMAX+1,r=Array.from({length:t},(n,s)=>lr(s,e));return Object.assign({},...r)},lr=function(e,t){let r=dr(e,t);if(r===void 0)return{};let{name:n,description:s,supported:i,action:o,forced:a,standard:u}=r;return{[e]:{name:n,number:e,description:s,supported:i,action:o,forced:a,standard:u}}},dr=function(e,t){let r=t.find(({name:n})=>sr.constants.signals[n]===e);return r!==void 0?r:t.find(n=>n.number===e)},fr=ur();G.signalsByNumber=fr});var Ot=c((Ds,At)=>{"use strict";var{signalsByName:pr}=Gt(),mr=({timedOut:e,timeout:t,errorCode:r,signal:n,signalDescription:s,exitCode:i,isCanceled:o})=>e?`timed out after ${t} milliseconds`:o?"was canceled":r!==void 0?`failed with ${r}`:n!==void 0?`was killed with ${n} (${s})`:i!==void 0?`failed with exit code ${i}`:"failed",hr=({stdout:e,stderr:t,all:r,error:n,signal:s,exitCode:i,command:o,escapedCommand:a,timedOut:u,isCanceled:l,killed:p,parsed:{options:{timeout:y}}})=>{i=i===null?void 0:i,s=s===null?void 0:s;let h=s===void 0?void 0:pr[s].description,S=n&&n.code,x=`Command ${mr({timedOut:u,timeout:y,errorCode:S,signal:s,signalDescription:h,exitCode:i,isCanceled:l})}: ${o}`,E=Object.prototype.toString.call(n)==="[object Error]",L=E?`${x}
${n.message}`:x,B=[L,t,e].filter(Boolean).join(`
`);return E?(n.originalMessage=n.message,n.message=B):n=new Error(B),n.shortMessage=L,n.command=o,n.escapedCommand=a,n.exitCode=i,n.signal=s,n.signalDescription=h,n.stdout=e,n.stderr=t,r!==void 0&&(n.all=r),"bufferedData"in n&&delete n.bufferedData,n.failed=!0,n.timedOut=Boolean(u),n.isCanceled=l,n.killed=p&&!u,n};At.exports=hr});var qt=c((Fs,fe)=>{"use strict";var K=["stdin","stdout","stderr"],yr=e=>K.some(t=>e[t]!==void 0),Rt=e=>{if(!e)return;let{stdio:t}=e;if(t===void 0)return K.map(n=>e[n]);if(yr(e))throw new Error(`It's not possible to provide \`stdio\` in combination with one of ${K.map(n=>`\`${n}\``).join(", ")}`);if(typeof t=="string")return t;if(!Array.isArray(t))throw new TypeError(`Expected \`stdio\` to be of type \`string\` or \`Array\`, got \`${typeof t}\``);let r=Math.max(t.length,K.length);return Array.from({length:r},(n,s)=>t[s])};fe.exports=Rt;fe.exports.node=e=>{let t=Rt(e);return t==="ipc"?"ipc":t===void 0||typeof t=="string"?[t,t,t,"ipc"]:t.includes("ipc")?t:[...t,"ipc"]}});var Nt=c((Hs,V)=>{V.exports=["SIGABRT","SIGALRM","SIGHUP","SIGINT","SIGTERM"];process.platform!=="win32"&&V.exports.push("SIGVTALRM","SIGXCPU","SIGXFSZ","SIGUSR2","SIGTRAP","SIGSYS","SIGQUIT","SIGIOT");process.platform==="linux"&&V.exports.push("SIGIO","SIGPOLL","SIGPWR","SIGSTKFLT","SIGUNUSED")});var Lt=c((Xs,R)=>{var f=global.process,v=function(e){return e&&typeof e=="object"&&typeof e.removeListener=="function"&&typeof e.emit=="function"&&typeof e.reallyExit=="function"&&typeof e.listeners=="function"&&typeof e.kill=="function"&&typeof e.pid=="number"&&typeof e.on=="function"};v(f)?(kt=require("assert"),A=Nt(),$t=/^win/i.test(f.platform),$=require("events"),typeof $!="function"&&($=$.EventEmitter),f.__signal_exit_emitter__?m=f.__signal_exit_emitter__:(m=f.__signal_exit_emitter__=new $,m.count=0,m.emitted={}),m.infinite||(m.setMaxListeners(1/0),m.infinite=!0),R.exports=function(e,t){if(!!v(global.process)){kt.equal(typeof e,"function","a callback must be provided for exit handler"),O===!1&&pe();var r="exit";t&&t.alwaysLast&&(r="afterexit");var n=function(){m.removeListener(r,e),m.listeners("exit").length===0&&m.listeners("afterexit").length===0&&W()};return m.on(r,e),n}},W=function(){!O||!v(global.process)||(O=!1,A.forEach(function(t){try{f.removeListener(t,Y[t])}catch{}}),f.emit=Q,f.reallyExit=me,m.count-=1)},R.exports.unload=W,I=function(t,r,n){m.emitted[t]||(m.emitted[t]=!0,m.emit(t,r,n))},Y={},A.forEach(function(e){Y[e]=function(){if(!!v(global.process)){var r=f.listeners(e);r.length===m.count&&(W(),I("exit",null,e),I("afterexit",null,e),$t&&e==="SIGHUP"&&(e="SIGINT"),f.kill(f.pid,e))}}}),R.exports.signals=function(){return A},O=!1,pe=function(){O||!v(global.process)||(O=!0,m.count+=1,A=A.filter(function(t){try{return f.on(t,Y[t]),!0}catch{return!1}}),f.emit=jt,f.reallyExit=_t)},R.exports.load=pe,me=f.reallyExit,_t=function(t){!v(global.process)||(f.exitCode=t||0,I("exit",f.exitCode,null),I("afterexit",f.exitCode,null),me.call(f,f.exitCode))},Q=f.emit,jt=function(t,r){if(t==="exit"&&v(global.process)){r!==void 0&&(f.exitCode=r);var n=Q.apply(this,arguments);return I("exit",f.exitCode,null),I("afterexit",f.exitCode,null),n}else return Q.apply(this,arguments)}):R.exports=function(){};var kt,A,$t,$,m,W,I,Y,O,pe,me,_t,Q,jt});var Mt=c((zs,Bt)=>{"use strict";var Sr=require("os"),gr=Lt(),xr=1e3*5,br=(e,t="SIGTERM",r={})=>{let n=e(t);return wr(e,t,r,n),n},wr=(e,t,r,n)=>{if(!vr(t,r,n))return;let s=Er(r),i=setTimeout(()=>{e("SIGKILL")},s);i.unref&&i.unref()},vr=(e,{forceKillAfterTimeout:t},r)=>Ir(e)&&t!==!1&&r,Ir=e=>e===Sr.constants.signals.SIGTERM||typeof e=="string"&&e.toUpperCase()==="SIGTERM",Er=({forceKillAfterTimeout:e=!0})=>{if(e===!0)return xr;if(!Number.isFinite(e)||e<0)throw new TypeError(`Expected the \`forceKillAfterTimeout\` option to be a non-negative integer, got \`${e}\` (${typeof e})`);return e},Tr=(e,t)=>{e.kill()&&(t.isCanceled=!0)},Cr=(e,t,r)=>{e.kill(t),r(Object.assign(new Error("Timed out"),{timedOut:!0,signal:t}))},Pr=(e,{timeout:t,killSignal:r="SIGTERM"},n)=>{if(t===0||t===void 0)return n;let s,i=new Promise((a,u)=>{s=setTimeout(()=>{Cr(e,r,u)},t)}),o=n.finally(()=>{clearTimeout(s)});return Promise.race([i,o])},Gr=({timeout:e})=>{if(e!==void 0&&(!Number.isFinite(e)||e<0))throw new TypeError(`Expected the \`timeout\` option to be a non-negative integer, got \`${e}\` (${typeof e})`)},Ar=async(e,{cleanup:t,detached:r},n)=>{if(!t||r)return n;let s=gr(()=>{e.kill()});return n.finally(()=>{s()})};Bt.exports={spawnedKill:br,spawnedCancel:Tr,setupTimeout:Pr,validateTimeout:Gr,setExitHandler:Ar}});var Dt=c((Ks,Ut)=>{"use strict";var w=e=>e!==null&&typeof e=="object"&&typeof e.pipe=="function";w.writable=e=>w(e)&&e.writable!==!1&&typeof e._write=="function"&&typeof e._writableState=="object";w.readable=e=>w(e)&&e.readable!==!1&&typeof e._read=="function"&&typeof e._readableState=="object";w.duplex=e=>w.writable(e)&&w.readable(e);w.transform=e=>w.duplex(e)&&typeof e._transform=="function";Ut.exports=w});var Ht=c((Vs,Ft)=>{"use strict";var{PassThrough:Or}=require("stream");Ft.exports=e=>{e={...e};let{array:t}=e,{encoding:r}=e,n=r==="buffer",s=!1;t?s=!(r||n):r=r||"utf8",n&&(r=null);let i=new Or({objectMode:s});r&&i.setEncoding(r);let o=0,a=[];return i.on("data",u=>{a.push(u),s?o=a.length:o+=u.length}),i.getBufferedValue=()=>t?a:n?Buffer.concat(a,o):a.join(""),i.getBufferedLength=()=>o,i}});var Xt=c((Ws,_)=>{"use strict";var{constants:Rr}=require("buffer"),qr=require("stream"),{promisify:Nr}=require("util"),kr=Ht(),$r=Nr(qr.pipeline),he=class extends Error{constructor(){super("maxBuffer exceeded");this.name="MaxBufferError"}};async function ye(e,t){if(!e)throw new Error("Expected a stream");t={maxBuffer:1/0,...t};let{maxBuffer:r}=t,n=kr(t);return await new Promise((s,i)=>{let o=a=>{a&&n.getBufferedLength()<=Rr.MAX_LENGTH&&(a.bufferedData=n.getBufferedValue()),i(a)};(async()=>{try{await $r(e,n),s()}catch(a){o(a)}})(),n.on("data",()=>{n.getBufferedLength()>r&&o(new he)})}),n.getBufferedValue()}_.exports=ye;_.exports.buffer=(e,t)=>ye(e,{...t,encoding:"buffer"});_.exports.array=(e,t)=>ye(e,{...t,array:!0});_.exports.MaxBufferError=he});var Kt=c((Ys,zt)=>{"use strict";var{PassThrough:_r}=require("stream");zt.exports=function(){var e=[],t=new _r({objectMode:!0});return t.setMaxListeners(0),t.add=r,t.isEmpty=n,t.on("unpipe",s),Array.prototype.slice.call(arguments).forEach(r),t;function r(i){return Array.isArray(i)?(i.forEach(r),this):(e.push(i),i.once("end",s.bind(null,i)),i.once("error",t.emit.bind(t,"error")),i.pipe(t,{end:!1}),this)}function n(){return e.length==0}function s(i){e=e.filter(function(o){return o!==i}),!e.length&&t.readable&&t.end()}}});var Qt=c((Qs,Yt)=>{"use strict";var Vt=Dt(),Wt=Xt(),jr=Kt(),Lr=(e,t)=>{t===void 0||e.stdin===void 0||(Vt(t)?t.pipe(e.stdin):e.stdin.end(t))},Br=(e,{all:t})=>{if(!t||!e.stdout&&!e.stderr)return;let r=jr();return e.stdout&&r.add(e.stdout),e.stderr&&r.add(e.stderr),r},Se=async(e,t)=>{if(!!e){e.destroy();try{return await t}catch(r){return r.bufferedData}}},ge=(e,{encoding:t,buffer:r,maxBuffer:n})=>{if(!(!e||!r))return t?Wt(e,{encoding:t,maxBuffer:n}):Wt.buffer(e,{maxBuffer:n})},Mr=async({stdout:e,stderr:t,all:r},{encoding:n,buffer:s,maxBuffer:i},o)=>{let a=ge(e,{encoding:n,buffer:s,maxBuffer:i}),u=ge(t,{encoding:n,buffer:s,maxBuffer:i}),l=ge(r,{encoding:n,buffer:s,maxBuffer:i*2});try{return await Promise.all([o,a,u,l])}catch(p){return Promise.all([{error:p,signal:p.signal,timedOut:p.timedOut},Se(e,a),Se(t,u),Se(r,l)])}},Ur=({input:e})=>{if(Vt(e))throw new TypeError("The `input` option cannot be a stream in sync mode")};Yt.exports={handleInput:Lr,makeAllStream:Br,getSpawnedResult:Mr,validateInputSync:Ur}});var Jt=c((Zs,Zt)=>{"use strict";var Dr=(async()=>{})().constructor.prototype,Fr=["then","catch","finally"].map(e=>[e,Reflect.getOwnPropertyDescriptor(Dr,e)]),Hr=(e,t)=>{for(let[r,n]of Fr){let s=typeof t=="function"?(...i)=>Reflect.apply(n.value,t(),i):n.value.bind(t);Reflect.defineProperty(e,r,{...n,value:s})}return e},Xr=e=>new Promise((t,r)=>{e.on("exit",(n,s)=>{t({exitCode:n,signal:s})}),e.on("error",n=>{r(n)}),e.stdin&&e.stdin.on("error",n=>{r(n)})});Zt.exports={mergePromise:Hr,getSpawnedPromise:Xr}});var nn=c((Js,tn)=>{"use strict";var en=(e,t=[])=>Array.isArray(t)?[e,...t]:[e],zr=/^[\w.-]+$/,Kr=/"/g,Vr=e=>typeof e!="string"||zr.test(e)?e:`"${e.replace(Kr,'\\"')}"`,Wr=(e,t)=>en(e,t).join(" "),Yr=(e,t)=>en(e,t).map(r=>Vr(r)).join(" "),Qr=/ +/g,Zr=e=>{let t=[];for(let r of e.trim().split(Qr)){let n=t[t.length-1];n&&n.endsWith("\\")?t[t.length-1]=`${n.slice(0,-1)} ${r}`:t.push(r)}return t};tn.exports={joinCommand:Wr,getEscapedCommand:Yr,parseCommand:Zr}});var ln=c((ei,q)=>{"use strict";var Jr=require("path"),xe=require("child_process"),es=pt(),ts=ht(),ns=gt(),rs=vt(),Z=Ot(),rn=qt(),{spawnedKill:ss,spawnedCancel:is,setupTimeout:os,validateTimeout:as,setExitHandler:cs}=Mt(),{handleInput:us,getSpawnedResult:ls,makeAllStream:ds,validateInputSync:fs}=Qt(),{mergePromise:sn,getSpawnedPromise:ps}=Jt(),{joinCommand:on,parseCommand:an,getEscapedCommand:cn}=nn(),ms=1e3*1e3*100,hs=({env:e,extendEnv:t,preferLocal:r,localDir:n,execPath:s})=>{let i=t?{...process.env,...e}:e;return r?ns.env({env:i,cwd:n,execPath:s}):i},un=(e,t,r={})=>{let n=es._parse(e,t,r);return e=n.command,t=n.args,r=n.options,r={maxBuffer:ms,buffer:!0,stripFinalNewline:!0,extendEnv:!0,preferLocal:!1,localDir:r.cwd||process.cwd(),execPath:process.execPath,encoding:"utf8",reject:!0,cleanup:!0,all:!1,windowsHide:!0,...r},r.env=hs(r),r.stdio=rn(r),process.platform==="win32"&&Jr.basename(e,".exe")==="cmd"&&t.unshift("/q"),{file:e,args:t,options:r,parsed:n}},j=(e,t,r)=>typeof t!="string"&&!Buffer.isBuffer(t)?r===void 0?void 0:"":e.stripFinalNewline?ts(t):t,J=(e,t,r)=>{let n=un(e,t,r),s=on(e,t),i=cn(e,t);as(n.options);let o;try{o=xe.spawn(n.file,n.args,n.options)}catch(S){let g=new xe.ChildProcess,x=Promise.reject(Z({error:S,stdout:"",stderr:"",all:"",command:s,escapedCommand:i,parsed:n,timedOut:!1,isCanceled:!1,killed:!1}));return sn(g,x)}let a=ps(o),u=os(o,n.options,a),l=cs(o,n.options,u),p={isCanceled:!1};o.kill=ss.bind(null,o.kill.bind(o)),o.cancel=is.bind(null,o,p);let h=rs(async()=>{let[{error:S,exitCode:g,signal:x,timedOut:E},L,B,hn]=await ls(o,n.options,l),ve=j(n.options,L),Ie=j(n.options,B),Ee=j(n.options,hn);if(S||g!==0||x!==null){let Te=Z({error:S,exitCode:g,signal:x,stdout:ve,stderr:Ie,all:Ee,command:s,escapedCommand:i,parsed:n,timedOut:E,isCanceled:p.isCanceled,killed:o.killed});if(!n.options.reject)return Te;throw Te}return{command:s,escapedCommand:i,exitCode:0,stdout:ve,stderr:Ie,all:Ee,failed:!1,timedOut:!1,isCanceled:!1,killed:!1}});return us(o,n.options.input),o.all=ds(o,n.options),sn(o,h)};q.exports=J;q.exports.sync=(e,t,r)=>{let n=un(e,t,r),s=on(e,t),i=cn(e,t);fs(n.options);let o;try{o=xe.spawnSync(n.file,n.args,n.options)}catch(l){throw Z({error:l,stdout:"",stderr:"",all:"",command:s,escapedCommand:i,parsed:n,timedOut:!1,isCanceled:!1,killed:!1})}let a=j(n.options,o.stdout,o.error),u=j(n.options,o.stderr,o.error);if(o.error||o.status!==0||o.signal!==null){let l=Z({stdout:a,stderr:u,error:o.error,signal:o.signal,exitCode:o.status,command:s,escapedCommand:i,parsed:n,timedOut:o.error&&o.error.code==="ETIMEDOUT",isCanceled:!1,killed:o.signal!==null});if(!n.options.reject)return l;throw l}return{command:s,escapedCommand:i,exitCode:0,stdout:a,stderr:u,failed:!1,timedOut:!1,isCanceled:!1,killed:!1}};q.exports.command=(e,t)=>{let[r,...n]=an(e);return J(r,n,t)};q.exports.commandSync=(e,t)=>{let[r,...n]=an(e);return J.sync(r,n,t)};q.exports.node=(e,t,r={})=>{t&&!Array.isArray(t)&&typeof t=="object"&&(r=t,t=[]);let n=rn.node(r),s=process.execArgv.filter(a=>!a.startsWith("--inspect")),{nodePath:i=process.execPath,nodeOptions:o=s}=r;return J(i,[...o,e,...Array.isArray(t)?t:[]],{...r,stdin:void 0,stdout:void 0,stderr:void 0,stdio:n,shell:!1})}});wn(exports,{default:()=>mn});var d=U(require("@raycast/api"));var b=U(require("@raycast/api"));var dn=U(require("process")),fn=U(ln());async function be(e){if(dn.default.platform!=="darwin")throw new Error("macOS only");let{stdout:t}=await(0,fn.default)("osascript",["-e",e]);return t}async function pn(e){await(0,b.closeMainWindow)();try{await be(e)}catch{await(0,b.showHUD)("HazeOver didn't respond! Check your HazeOver installation.")}}async function we(e){try{await be(e),await(0,b.closeMainWindow)()}catch{await(0,b.showToast)(b.ToastStyle.Failure,"HazeOver didn't respond!","Check your HazeOver installation.")}await(0,b.popToRoot)()}async function ys(e){let t=`
    tell application "HazeOver"
      if intensity + ${e} > 100 then
        set intensity to 100
      else
        set intensity to intensity + ${e} 
      end if
    end tell
  `;await we(t)}async function Ss(e){let t=`
    tell application "HazeOver"
      if intensity - ${e} < 0 then
        set intensity to 0
      else
        set intensity to intensity - ${e} 
      end if
    end tell
  `;await we(t)}var gs=[0,10,20,25,30,40,50,60,70,75,80,90,100];function mn(){return _jsx(d.List,{navigationTitle:"Change Dimming Intensity"},_jsx(d.List.Item,{title:"Set Intensity",subtitle:"0-100%",icon:{source:d.Icon.Dot,tintColor:d.Color.Blue},actions:_jsx(d.ActionPanel,{title:"Set Intensity"},_jsx(d.ActionPanel.Submenu,{title:"Percentage Values",icon:{source:d.Icon.Text,tintColor:d.Color.PrimaryText}},gs.map(e=>_jsx(d.ActionPanel.Item,{key:e.toString(),title:e.toString(),onAction:()=>pn(`tell application "HazeOver" to set intensity to ${e}`)}))))}),_jsx(d.List.Item,{title:"Increment Intensity",subtitle:"+20%",icon:{source:d.Icon.ChevronUp,tintColor:d.Color.Green},keywords:["add","plus","higher","more"],actions:_jsx(d.ActionPanel,{title:"Increment Intensity"},_jsx(d.ActionPanel.Item,{icon:{source:d.Icon.ChevronUp,tintColor:d.Color.Green},title:"Increment Intensity",onAction:()=>ys(20)}))}),_jsx(d.List.Item,{title:"Decrement Intensity",subtitle:"-20%",icon:{source:d.Icon.ChevronDown,tintColor:d.Color.Red},keywords:["subtract","minus","lower","less"],actions:_jsx(d.ActionPanel,{title:"Decrement Intensity"},_jsx(d.ActionPanel.Item,{icon:{source:d.Icon.ChevronDown,tintColor:d.Color.Red},title:"Decrement Intensity",onAction:()=>Ss(20)}))}))}0&&(module.exports={});
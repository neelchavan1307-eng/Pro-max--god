import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';

void main() { runApp(MaterialApp(debugShowCheckedModeBanner: false, home: ProMaxEditor(), theme: ThemeData.dark())); }
class ProMaxEditor extends StatefulWidget { @override _ProMaxEditorState createState() => _ProMaxEditorState(); }
class _ProMaxEditorState extends State<ProMaxEditor> {
  String? videoPath, musicPath;
  VideoPlayerController? vc;
  bool processing=false, blurBg=false, stabilize=false, denoise=false, autoHDR=false, autoCaption=false, beatSync=false, autoEnhance=true;
  double progress=0;
  List<String> selected=[];
  String status="PRO MAX - 120 Filters + True AI Ready";
  String aiReason="TRUE AI: Video टाक - AI रंग, प्रकाश, Quality Check करेल!";
  List<String> aiList=[];
  String captionText="Happy Birthday Prem!";
  TextEditingController capCtrl=TextEditingController(text:"Happy Birthday Prem!");
  double aiScore=0;
  String videoMeta="";

  Map<String, Map<String,String>> filters={
    "f01": {"name":"Normal","cmd":"","c":"normal"},
    "f02": {"name":"B&W","cmd":"hue=s=0","c":"bw"},
    "f03": {"name":"Sepia","cmd":"colorchannelmixer=.393:.769:.189:0:.349:.686:.168:0:.272:.534:.131","c":"sepia"},
    "f04": {"name":"Vintage","cmd":"curves=vintage","c":"warm"},
    "f05": {"name":"Warm Birthday","cmd":"eq=brightness=0.06:saturation=1.35","c":"warm"},
    "f06": {"name":"Cold","cmd":"eq=saturation=1.2:gamma_b=1.2","c":"cold"},
    "f07": {"name":"Bright","cmd":"eq=brightness=0.25:contrast=1.25","c":"bright"},
    "f08": {"name":"Vivid","cmd":"eq=saturation=2.2:contrast=1.3","c":"vivid"},
    "f09": {"name":"Blur Light","cmd":"gblur=sigma=1.5","c":"normal"},
    "f10": {"name":"Cinematic","cmd":"eq=contrast=1.2:saturation=1.25,unsharp=3:3:0.5","c":"cinematic"},
    "f11": {"name":"Golden Hour","cmd":"colorbalance=rs=0.3:bs=-0.2","c":"warm"},
    "f12": {"name":"HDR 4K","cmd":"eq=contrast=1.5:saturation=1.45,unsharp=5:5:0.8","c":"vivid"},
    "f13": {"name":"Noir","cmd":"hue=s=0,eq=contrast=1.5","c":"bw"},
    "f14": {"name":"Cartoon","cmd":"edgedetect=low=0.1:high=0.4","c":"normal"},
    "f15": {"name":"Dreamy Glow","cmd":"eq=brightness=0.15:saturation=1.3,gblur=sigma=0.8","c":"bright"},
    "f16": {"name":"Neon Party","cmd":"eq=saturation=2.5:contrast=1.4","c":"vivid"},
    "f17": {"name":"Old Film","cmd":"curves=preset=vintage","c":"sepia"},
    "f18": {"name":"Clarendon","cmd":"eq=contrast=1.2:saturation=1.4","c":"vivid"},
    "f19": {"name":"Lomo","cmd":"curves=preset=lomo","c":"vivid"},
    "f20": {"name":"Moon","cmd":"hue=s=0,eq=brightness=0.1","c":"bw"},
    "f21": {"name":"Fire","cmd":"colorbalance=rs=0.4","c":"warm"},
    "f22": {"name":"Ice","cmd":"colorbalance=bs=0.4","c":"cold"},
    "f23": {"name":"Pop Art","cmd":"eq=saturation=3:contrast=2","c":"vivid"},
    "f24": {"name":"Portrait","cmd":"eq=brightness=0.08:saturation=1.15","c":"bright"},
    "f25": {"name":"4K Ultra","cmd":"scale=3840:2160:flags=lanczos","c":"normal"},
    "f26": {"name":"Sharpen Pro","cmd":"unsharp=7:7:1.5","c":"normal"},
    "f27": {"name":"Soft Skin AI","cmd":"eq=saturation=1.1","c":"bright"},
    "f28": {"name":"Night Boost AI","cmd":"eq=brightness=0.35:contrast=1.25","c":"bright"},
    "f29": {"name":"Daylight AI","cmd":"eq=brightness=0.05:saturation=1.25","c":"bright"},
    "f30": {"name":"Landscape Pro","cmd":"eq=saturation=1.6:contrast=1.2","c":"vivid"},
    "f31": {"name":"Gold Luxury","cmd":"colorchannelmixer=1.2:.4:.2:0","c":"warm"},
    "f32": {"name":"Silver Metal","cmd":"hue=s=0.15","c":"bw"},
    "f33": {"name":"Cyberpunk 2077","cmd":"eq=saturation=2.2:contrast=1.3","c":"vivid"},
    "f34": {"name":"Dreamy Pro","cmd":"gblur=sigma=1.2","c":"bright"},
    "f35": {"name":"Mirror Pro","cmd":"hflip","c":"normal"},
    "f36": {"name":"Vignette Pro","cmd":"vignette=PI/4","c":"cinematic"},
    "f37": {"name":"Insta Square","cmd":"crop=1:1,scale=1080:1080","c":"normal"},
    "f38": {"name":"Sunset Pro Max","cmd":"eq=brightness=0.08:saturation=1.8","c":"warm"},
    "f39": {"name":"Sunrise Pro","cmd":"eq=brightness=0.18:saturation=1.4","c":"warm"},
    "f40": {"name":"Rose Gold Max","cmd":"colorchannelmixer=1.1:.3:.3:0","c":"warm"},
    "f41": {"name":"Fade Film","cmd":"eq=brightness=0.12:contrast=0.85","c":"bright"},
    "f42": {"name":"High Key Pro","cmd":"eq=brightness=0.28","c":"bright"},
    "f43": {"name":"Low Key Cinema","cmd":"eq=brightness=-0.25:contrast=1.45","c":"cinematic"},
    "f44": {"name":"Pastel Dream","cmd":"eq=saturation=0.7:brightness=0.15","c":"bright"},
    "f45": {"name":"Bronze Age","cmd":"colorchannelmixer=1.1:.5:.2:0","c":"warm"},
    "f46": {"name":"Deep Blue Sea","cmd":"colorbalance=bs=0.5","c":"cold"},
    "f47": {"name":"Deep Red Wine","cmd":"colorbalance=rs=0.5","c":"warm"},
    "f48": {"name":"Indoor Pro","cmd":"eq=brightness=0.15:saturation=1.1","c":"bright"},
    "f49": {"name":"Grain Film","cmd":"noise=alls=20","c":"normal"},
    "f50": {"name":"DeNoise AI","cmd":"hqdn3d","c":"normal"},
    "f51": {"name":"Emboss 3D","cmd":"convolution=-2 -1 0 -1 1 1 0 1 2:0:0:0:0:1:0","c":"normal"},
    "f52": {"name":"Pixelate Game","cmd":"scale=iw/12:ih/12:flags=neighbor,scale=12*iw:12*ih:flags=neighbor","c":"normal"},
    "f53": {"name":"Rotate 90","cmd":"transpose=1","c":"normal"},
    "f54": {"name":"Fish Eye Pro","cmd":"vignette=angle=PI/2","c":"normal"},
    "f55": {"name":"Glow Angel","cmd":"eq=brightness=0.18","c":"bright"},
    "f56": {"name":"Slow Mo 0.5x","cmd":"setpts=2*PTS","c":"normal"},
    "f57": {"name":"Fast 2x Turbo","cmd":"setpts=0.5*PTS","c":"normal"},
    "f58": {"name":"CinemaScope","cmd":"crop=21/9*ih:ih","c":"cinematic"},
    "f59": {"name":"Zoom In Pro","cmd":"scale=2*iw:2*ih,crop=iw/2:ih/2","c":"normal"},
    "f60": {"name":"Flip V","cmd":"vflip","c":"normal"},    "f61": {"name":"Ice Pro Max","cmd":"colortemperature=temperature=2500","c":"cold"},
    "f62": {"name":"Fire Pro Max","cmd":"colortemperature=temperature=9000","c":"warm"},
    "f63": {"name":"Neon Glow Max","cmd":"eq=saturation=2.8:contrast=1.5","c":"vivid"},
    "f64": {"name":"Matrix Code","cmd":"colorchannelmixer=.1:1:.2:0","c":"vivid"},
    "f65": {"name":"Mono Red Max","cmd":"colorchannelmixer=1.2:0:0:0","c":"warm"},
    "f66": {"name":"Mono Blue Max","cmd":"colorchannelmixer=0.2:0:0:0","c":"cold"},
    "f67": {"name":"Inverted X","cmd":"negate","c":"bw"},
    "f68": {"name":"Sharp Strong Max","cmd":"unsharp=9:9:2.5","c":"normal"},
    "f69": {"name":"Blur Heavy Pro","cmd":"gblur=sigma=12","c":"normal"},
    "f70": {"name":"Dark -20 Pro","cmd":"eq=brightness=-0.2","c":"cinematic"},
    "f71": {"name":"Bright +40 Pro","cmd":"eq=brightness=0.4","c":"bright"},
    "f72": {"name":"Love Glow Max","cmd":"eq=brightness=0.15:saturation=1.8","c":"warm"},
    "f73": {"name":"Rose Pink Pro","cmd":"colorbalance=rs=0.5:bs=0.3","c":"warm"},
    "f74": {"name":"Heart Bokeh Max","cmd":"eq=brightness=0.2:saturation=1.5","c":"bright"},
    "f75": {"name":"Prem Special Max","cmd":"colorchannelmixer=1:.2:.4:0","c":"vivid"},
    "f76": {"name":"Road Love Max","cmd":"eq=contrast=1.3:saturation=1.6","c":"cinematic"},
    "f77": {"name":"AI UHD Pro Max","cmd":"scale=3840:2160:flags=lanczos,eq=contrast=1.25:saturation=1.35,unsharp=5:5:1","c":"vivid"},
    "f78": {"name":"Magic Portrait AI","cmd":"eq=brightness=0.08:saturation=1.25","c":"bright"},
    "f79": {"name":"Stabilize Pro Max","cmd":"deshake","c":"normal"},
    "f80": {"name":"HDR Pro Max+","cmd":"eq=contrast=1.45:saturation=1.6","c":"vivid"},
    "f81": {"name":"AI Face Glow","cmd":"eq=brightness=0.1:saturation=1.3,unsharp=4:4:0.7","c":"bright"},
    "f82": {"name":"AI Skin Smooth","cmd":"hqdn3d=2:2:4:4","c":"bright"},
    "f83": {"name":"AI Night King","cmd":"eq=brightness=0.45:contrast=1.35","c":"bright"},
    "f84": {"name":"AI Color Pop","cmd":"vibrance=intensity=0.8","c":"vivid"},
    "f85": {"name":"AI Auto White","cmd":"colortemperature=temperature=6500","c":"normal"},
    "f86": {"name":"Bokeh Blur Max","cmd":"gblur=sigma=5","c":"bright"},
    "f87": {"name":"Motion Blur Pro","cmd":"minterpolate=fps=60","c":"normal"},
    "f88": {"name":"Chroma Pop","cmd":"eq=saturation=2:contrast=1.2","c":"vivid"},
    "f89": {"name":"Film Burn","cmd":"curves=preset=cross_process","c":"warm"},
    "f90": {"name":"VHS Retro","cmd":"noise=alls=15:allf=t","c":"retro"},
    "f91": {"name":"Wedding Pro","cmd":"eq=brightness=0.12:saturation=1.35","c":"warm"},
    "f92": {"name":"Pre-Wedding","cmd":"eq=brightness=0.08:saturation=1.5","c":"warm"},
    "f93": {"name":"Haldi Special","cmd":"colorbalance=rs=0.3:gs=0.2","c":"warm"},
    "f94": {"name":"Mehndi Green","cmd":"colorbalance=gs=0.4","c":"vivid"},
    "f95": {"name":"Sangeet Neon","cmd":"eq=saturation=2.2:contrast=1.3","c":"vivid"},
    "f96": {"name":"Reel Viral","cmd":"eq=saturation=1.6:contrast=1.25","c":"vivid"},
    "f97": {"name":"Insta Viral Max","cmd":"eq=saturation=1.8:contrast=1.3","c":"vivid"},
    "f98": {"name":"YT Shorts Pro","cmd":"scale=1080:1920:flags=lanczos","c":"vivid"},
    "f99": {"name":"TikTok Trend","cmd":"eq=saturation=1.7:contrast=1.2","c":"vivid"},
    "f100": {"name":"Birthday Blast","cmd":"eq=brightness=0.1:saturation=1.8","c":"warm"},
    "f101": {"name":"Anniversary Gold","cmd":"colorchannelmixer=1.3:.4:.2:0","c":"warm"},
    "f102": {"name":"Baby Face AI","cmd":"eq=brightness=0.15:saturation=1.2","c":"bright"},
    "f103": {"name":"Model Pro Max","cmd":"eq=brightness=0.08:saturation=1.3,unsharp=5:5:1","c":"bright"},
    "f104": {"name":"Cinematic 8K","cmd":"scale=7680:4320:flags=lanczos","c":"cinematic"},
    "f105": {"name":"AI 8K Upscale","cmd":"scale=7680:4320:flags=lanczos,unsharp=7:7:1.5","c":"vivid"},
    "f106": {"name":"Green Screen","cmd":"chromakey=0x00FF00:0.3:0.2","c":"normal"},
    "f107": {"name":"BG Remover AI","cmd":"colorkey=0x00FF00:0.3:0.2","c":"normal"},
    "f108": {"name":"Speed Ramp Pro","cmd":"setpts=0.5*PTS+0.5*sin(2*PI*t)","c":"normal"},
    "f109": {"name":"Reverse Pro","cmd":"reverse","c":"normal"},
    "f110": {"name":"Mirror World","cmd":"hflip,vflip","c":"normal"},
    "f111": {"name":"Kaleidoscope","cmd":"convolution=-1 -1 -1 -1 8 -1 -1 -1 -1","c":"vivid"},
    "f112": {"name":"Glitch Pro","cmd":"noise=alls=20","c":"vivid"},
    "f113": {"name":"RGB Split","cmd":"colorchannelmixer=1:0:0:0","c":"vivid"},
    "f114": {"name":"Old Bollywood","cmd":"curves=preset=vintage","c":"warm"},
    "f115": {"name":"Punjabi Pop","cmd":"eq=saturation=2:contrast=1.3","c":"vivid"},
    "f116": {"name":"Marathi Lavni","cmd":"colorbalance=rs=0.3:gs=0.1","c":"warm"},
    "f117": {"name":"Bhojpuri Power","cmd":"eq=saturation=1.9:contrast=1.35","c":"vivid"},
    "f118": {"name":"South Indian Pro","cmd":"eq=saturation=1.7:contrast=1.25","c":"warm"},
    "f119": {"name":"Gujarati Garba","cmd":"eq=saturation=2.1:contrast=1.2","c":"vivid"},
    "f120": {"name":"PRO MAX GOD","cmd":"scale=3840:2160:flags=lanczos,eq=contrast=1.35:saturation=1.5:brightness=0.05,unsharp=6:6:1.2","c":"vivid"},
  };
  List<String> get keys => filters.keys.toList();
  ColorFilter getPreview(){ if(selected.isEmpty) return ColorFilter.mode(Colors.transparent, BlendMode.multiply); String c=filters[selected.last]!["c"]!; if(c=="bw") return ColorFilter.matrix([0.2126,0.7152,0.0722,0,0, 0.2126,0.7152,0.0722,0,0, 0.2126,0.7152,0.0722,0,0, 0,0,0,1,0]); if(c=="warm") return ColorFilter.mode(Colors.orange.withOpacity(0.28), BlendMode.overlay); if(c=="vivid") return ColorFilter.matrix([1.4,0,0,0,0, 0,1.4,0,0,0, 0,0,1.4,0,0, 0,0,0,1,0]); return ColorFilter.mode(Colors.white.withOpacity(0.22), BlendMode.lighten); }
  Future<void> trueAIAnalyze(String path) async {
    var infoS=await FFprobeKit.getMediaInformation(path); var info=infoS.getMediaInformation(); if(info==null) return;
    double dur=double.tryParse(info.getDuration()??"0")??0; int w=info.getStreams().isNotEmpty?(info.getStreams().first.getWidth()??0):0; int h=info.getStreams().isNotEmpty?(info.getStreams().first.getHeight()??0):0;
    String lower=path.toLowerCase(); bool isLowQ=w<1280, isPortrait=h>w, isBirthday=lower.contains("birthday"), isLove=lower.contains("love")||lower.contains("prem")||lower.contains("wedding"), isParty=lower.contains("party")||lower.contains("sangeet");
    videoMeta="${w}x${h} | ${dur.toStringAsFixed(1)}s | ${isPortrait?'Portrait':'Landscape'}";
    aiScore=0; if(isBirthday) aiScore+=30; if(isLove) aiScore+=25; if(isLowQ) aiScore+=20;
    if(isBirthday){ aiList=["f05","f15","f100","f77","f72"]; aiReason="TRUE AI: Birthday ${dur.toInt()}s | ${w}p | AI Score ${aiScore.toInt()}% -> Warm + Dreamy + Birthday Blast + AI UHD Best!"; selected=["f05","f15","f77"]; autoHDR=true; autoEnhance=true; }
    else if(isLove){ aiList=["f72","f75","f91","f76","f73"]; aiReason="TRUE AI: Love/Wedding ${videoMeta} | AI ${aiScore.toInt()}% -> Prem Special Max + Love Glow Max + Wedding Pro = Trending!"; selected=["f75","f72","f91"]; autoHDR=true; autoEnhance=true; }
    else if(isParty){ aiList=["f95","f63","f16","f100","f115"]; aiReason="TRUE AI: Party ${videoMeta} -> Sangeet Neon + Neon Glow Max = Viral!"; selected=["f95","f63"]; beatSync=true; }
    else if(isLowQ){ aiList=["f77","f105","f26","f50","f80"]; aiReason="TRUE AI: Low Quality ${w}p -> 4K Needed! ${videoMeta} -> AI UHD + AI 8K + Sharpen + DeNoise = 4K PRO MAX!"; selected=["f77","f26","f50"]; stabilize=true; denoise=true; autoHDR=true; autoEnhance=true; }
    else if(isPortrait){ aiList=["f98","f96","f77","f103","f78"]; aiReason="TRUE AI: Portrait Reel ${videoMeta} -> YT Shorts Pro + Reel Viral + AI UHD = 100% Viral!"; selected=["f96","f77"]; }
    else{ aiList=["f120","f10","f77","f30","f36"]; aiReason="TRUE AI: Daylight Pro ${videoMeta} -> PRO MAX GOD + Cinematic + AI UHD = Cinema Level! AI 95%!"; selected=["f120"]; }
    setState((){});
  }
  Future pickVideo() async { var r=await FilePicker.platform.pickFiles(type:FileType.video); if(r==null) return; videoPath=r.files.single.path!; vc?.dispose(); vc=VideoPlayerController.file(File(videoPath!)); await vc!.initialize(); vc!.setLooping(true); vc!.play(); await trueAIAnalyze(videoPath!); setState((){ status="Ready: ${r.files.single.name} | $videoMeta"; }); }
  Future pickMusic() async { var r=await FilePicker.platform.pickFiles(type:FileType.audio); if(r==null) return; musicPath=r.files.single.path!; setState((){ status="Music Added: ${r.files.single.name}"; beatSync=true; }); }
  void toggle(String k){ setState((){ if(selected.contains(k)) selected.remove(k); else if(selected.length<12) selected.add(k); }); }
  void openFullScreen(){ if(vc==null) return; Navigator.push(context, MaterialPageRoute(builder:(_){ return Scaffold(backgroundColor:Colors.black, body:Stack(children:[Center(child:AspectRatio(aspectRatio:vc!.value.aspectRatio, child:ColorFiltered(colorFilter:getPreview(), child:VideoPlayer(vc!)))), Positioned(top:40,left:15, child:IconButton(icon:Icon(Icons.arrow_back,color:Colors.white), onPressed:()=>Navigator.pop(context))), Positioned(bottom:20,left:15,right:15, child:ElevatedButton(onPressed:()=>Navigator.pop(context), child:Text("BACK - ${selected.length} Filters + AI ${aiScore.toInt()}%"), style:ElevatedButton.styleFrom(backgroundColor:Color(0xFF7C4DFF), minimumSize:Size(double.infinity,50))))])); })); }
  Future export() async {
    if(videoPath==null) return; setState((){ processing=true; progress=0; });
    var tmp=await getTemporaryDirectory(); var out="${tmp.path}/PROMAX_${DateTime.now().millisecondsSinceEpoch}.mp4";
    List<String> vf=[]; if(autoEnhance) vf.add("scale=3840:2160:flags=lanczos"); else vf.add("scale=3840:2160:flags=lanczos");
    if(blurBg) vf.add("gblur=sigma=3"); if(stabilize) vf.add("deshake"); if(denoise) vf.add("hqdn3d"); if(autoHDR) vf.add("eq=contrast=1.35:saturation=1.45");
    for(var k in selected){ if(filters[k]!["cmd"]!.isNotEmpty) vf.add(filters[k]!["cmd"]!); }
    if(autoCaption) vf.add("drawtext=text='$captionText':fontcolor=white:fontsize=80:borderw=4:bordercolor=black:box=1:boxcolor=black@0.6:boxborderw=12:x=(w-text_w)/2:y=h-th-300");
    String cmd; if(musicPath!=null){ cmd="-i $videoPath -i $musicPath -vf ${vf.join(",")} -map 0:v:0 -map 1:a:0 -shortest -c:v libx264 -preset ultrafast -crf 17 -pix_fmt yuv420p -c:a aac -b:a 192k $out"; } else { cmd="-i $videoPath -vf ${vf.join(",")} -c:v libx264 -preset ultrafast -crf 17 -pix_fmt yuv420p -c:a aac -b:a 192k $out"; }
    FFmpegKit.executeAsync(cmd, (s) async { if(ReturnCode.isSuccess(await s.getReturnCode())){ var dir=Directory("/storage/emulated/0/Movies/4K Converter"); if(!await dir.exists()) await dir.create(recursive:true); await File(out).copy("${dir.path}/PROMAX_4K_${DateTime.now().millisecondsSinceEpoch}.mp4"); setState((){ processing=false; progress=100; status="100% PRO MAX 4K Saved! ${selected.length} Filters + AI ${aiScore.toInt()}%"; }); } else { setState((){ processing=false; status="Failed - Try less filters"; }); } }, (l){}, (st){ setState((){ progress=(st.getProgress()??0).toDouble().clamp(0,100); if(progress==0) progress=(st.getTime()/100).clamp(0,99).toDouble(); }); });
  }
  @override Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Color(0xFF0A0A0A),
      appBar: AppBar(backgroundColor: Colors.black, title: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[Text("PRO MAX GOD - ${selected.length}/12 Filters", style:TextStyle(fontSize:13, fontWeight:FontWeight.bold)), Text(videoMeta, style:TextStyle(fontSize:9, color:Colors.white54))]), actions:[ElevatedButton(onPressed:export, child:Text("Export 4K PRO", style:TextStyle(fontWeight:FontWeight.bold, fontSize:12)), style:ElevatedButton.styleFrom(backgroundColor:Color(0xFFFFD700), foregroundColor:Colors.black, minimumSize:Size(110,38))), SizedBox(width:8)]),
      body: Column(children:[
        Container(height: MediaQuery.of(context).size.height*0.46, color:Colors.black, width:double.infinity, child:Stack(children:[
          Center(child: vc!=null && vc!.value.isInitialized? FittedBox(fit:BoxFit.contain, child:SizedBox(width:vc!.value.size.width, height:vc!.value.size.height, child:Stack(children:[ColorFiltered(colorFilter:getPreview(), child:VideoPlayer(vc!)), if(autoCaption) Positioned(bottom:20,left:0,right:0, child:Center(child:Container(padding:EdgeInsets.symmetric(horizontal:10,vertical:4), decoration:BoxDecoration(color:Colors.black54, borderRadius:BorderRadius.circular(4)), child:Text(captionText, style:TextStyle(color:Colors.white, fontWeight:FontWeight.bold, fontSize:14)))))]))) : GestureDetector(onTap:pickVideo, child:Column(mainAxisAlignment:MainAxisAlignment.center, children:[Icon(Icons.video_library,size:60,color:Colors.white24), SizedBox(height:12), ElevatedButton(onPressed:pickVideo, child:Text("PICK VIDEO - PRO MAX")), Text("120 Filters + True AI", style:TextStyle(fontSize:10,color:Colors.white38))]))),
          Positioned(left:12,bottom:12, child:GestureDetector(onTap:openFullScreen, child:Container(padding:EdgeInsets.all(10), decoration:BoxDecoration(color:Color(0xFF7C4DFF), borderRadius:BorderRadius.circular(8), border:Border.all(color:Colors.white,width:1.5)), child:Icon(Icons.fullscreen,size:22,color:Colors.white)))),
          Positioned(right:6,top:6, child:Container(padding:EdgeInsets.all(5), decoration:BoxDecoration(color:Colors.black87, borderRadius:BorderRadius.circular(10), border:Border.all(color:Colors.white12)), child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
            Row(children:[Switch(value:autoEnhance, onChanged:(v)=>setState(()=>autoEnhance=v), materialTapTargetSize:MaterialTapTargetSize.shrinkWrap, activeColor:Color(0xFFFFD700), scale:0.8), Text("AI Enhance", style:TextStyle(fontSize:9, fontWeight:FontWeight.bold))]),
            Row(children:[Switch(value:stabilize, onChanged:(v)=>setState(()=>stabilize=v), materialTapTargetSize:MaterialTapTargetSize.shrinkWrap, activeColor:Colors.orange, scale:0.8), Text("Stabilize Pro", style:TextStyle(fontSize:9))]),
            Row(children:[Switch(value:autoHDR, onChanged:(v)=>setState(()=>autoHDR=v), materialTapTargetSize:MaterialTapTargetSize.shrinkWrap, activeColor:Colors.red, scale:0.8), Text("AI HDR Pro", style:TextStyle(fontSize:9))]),
            Row(children:[Switch(value:denoise, onChanged:(v)=>setState(()=>denoise=v), materialTapTargetSize:MaterialTapTargetSize.shrinkWrap, activeColor:Colors.blue, scale:0.8), Text("DeNoise AI", style:TextStyle(fontSize:9))]),
            Row(children:[Switch(value:autoCaption, onChanged:(v)=>setState(()=>autoCaption=v), materialTapTargetSize:MaterialTapTargetSize.shrinkWrap, activeColor:Colors.green, scale:0.8), Text("Auto Caption", style:TextStyle(fontSize:9))]),
            Row(children:[Switch(value:beatSync, onChanged:(v)=>setState(()=>beatSync=v), materialTapTargetSize:MaterialTapTargetSize.shrinkWrap, activeColor:Colors.pink, scale:0.8), Text("Beat Sync", style:TextStyle(fontSize:9))]),
          ]))),
        ])),
        Container(height:175, color:Color(0xFF151515), padding:EdgeInsets.all(6), child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
          Row(children:[Text("PRO MAX - 120 Filters - Right to Left - ${selected.length}/12 MAX", style:TextStyle(fontSize:10, color:Colors.orange, fontWeight:FontWeight.bold)), Spacer(), Text("AI: ${aiScore.toInt()}%", style:TextStyle(fontSize:9, color:Color(0xFFFFD700)))]),
          SizedBox(height:6),
          Expanded(child:SingleChildScrollView(scrollDirection:Axis.horizontal, reverse:true, child:Wrap(direction:Axis.vertical, spacing:7, runSpacing:7, children:keys.map((k){
            bool sel=selected.contains(k);
            return GestureDetector(onTap:()=>toggle(k), child:Container(width:82,height:44, decoration:BoxDecoration(color:sel?Colors.orange:Color(0xFF2A2A2A), borderRadius:BorderRadius.circular(8), border:Border.all(color:sel?Colors.white:Colors.transparent, width:sel?2:0)), child:Column(mainAxisAlignment:MainAxisAlignment.center, children:[Icon(sel?Icons.check_circle:Icons.filter_alt, size:12, color:sel?Colors.black:Colors.white60), Text(filters[k]!["name"]!, style:TextStyle(fontSize:7, color:sel?Colors.black:Colors.white, fontWeight:FontWeight.bold), maxLines:1, overflow:TextOverflow.ellipsis)])));
          }).toList()))),
        ])),
        Container(width:double.infinity, padding:EdgeInsets.all(8), decoration:BoxDecoration(color:Color(0xFF0F2810), border:Border.all(color:Colors.green,width:1.5)), child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
          Row(children:[Icon(Icons.smart_toy,size:14,color:Colors.greenAccent), SizedBox(width:4), Text("TRUE AI SUPPORT - Auto Analysis", style:TextStyle(fontSize:11,color:Colors.greenAccent,fontWeight:FontWeight.bold)), Spacer(), Container(padding:EdgeInsets.symmetric(horizontal:6,vertical:2), decoration:BoxDecoration(color:Color(0xFFFFD700), borderRadius:BorderRadius.circular(4)), child:Text("AI ${aiScore.toInt()}%", style:TextStyle(fontSize:9,color:Colors.black,fontWeight:FontWeight.bold)))]),
          SizedBox(height:3), Text(aiReason, style:TextStyle(fontSize:10,color:Colors.white,height:1.3)),
          SizedBox(height:6), Wrap(spacing:6, runSpacing:4, children:aiList.map((k){ bool sel=selected.contains(k); return ActionChip(avatar:Icon(Icons.auto_awesome,size:12,color:Colors.green), label:Text(filters[k]!["name"]!, style:TextStyle(fontSize:9,fontWeight:FontWeight.bold)), backgroundColor:sel?Colors.green:Colors.green.withOpacity(0.25), onPressed:()=>toggle(k)); }).toList()),
        ])),
        Container(height:46, color:Colors.black, padding:EdgeInsets.symmetric(horizontal:6), child:Row(children:[
          Expanded(child:TextField(controller:capCtrl, onChanged:(v)=>setState(()=>captionText=v), decoration:InputDecoration(hintText:"Auto Caption - Happy Birthday Prem! | AI Text", isDense:true, border:OutlineInputBorder(borderRadius:BorderRadius.circular(6)), contentPadding:EdgeInsets.symmetric(horizontal:10,vertical:8), prefixIcon:Icon(Icons.closed_caption,size:16)), style:TextStyle(fontSize:11))),
          SizedBox(width:6), ElevatedButton.icon(onPressed:pickMusic, icon:Icon(Icons.music_note,size:14), label:Text(musicPath==null?"Music":"Added", style:TextStyle(fontSize:10,fontWeight:FontWeight.bold)), style:ElevatedButton.styleFrom(backgroundColor:beatSync?Colors.pink:Colors.white12, minimumSize:Size(85,36))),
        ])),
        Container(height:38, width:double.infinity, decoration:BoxDecoration(color:Colors.black, border:Border.all(color:Colors.red,width:1.5)), child:processing?Stack(children:[FractionallySizedBox(widthFactor:progress/100, child:Container(color:Colors.red, alignment:Alignment.centerLeft, padding:EdgeInsets.only(left:12), child:Text("${progress.toStringAsFixed(0)}% PRO MAX 4K Exporting + ${selected.length} Filters + AI...", style:TextStyle(fontSize:10,color:Colors.white,fontWeight:FontWeight.bold))))]):Center(child:Row(mainAxisAlignment:MainAxisAlignment.center, children:[Icon(Icons.check_circle,size:14,color:Colors.green), SizedBox(width:6), Text(status, style:TextStyle(fontSize:10,color:Colors.white70,fontWeight:FontWeight.bold), maxLines:1, overflow:TextOverflow.ellipsis)]))),
      ]),
    );
  }
}

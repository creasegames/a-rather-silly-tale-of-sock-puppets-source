package game

import rl "vendor:raylib"
import "core:log"
sock :: struct{
	position : rl.Vector2,
	sockbox : rl.Vector2,
	talkbox : rl.Vector2,
	texture : ^rl.Texture,
}

dialogue :: struct{
	x : i32,
	y : i32,
	words : [4]cstring,
	update : ^bool,
}

events :: enum int {
	king,
	dinosaur,
	pirates,
	mountain,
	choose,
	picking,
	thanksyou,
}

curDia :dialogue=defaultDialogue
diaStep :i32=0
acceptNA :=true
defaultDialogue :dialogue={0,0,{"","","",""},&acceptNA}
diaSys :: proc(thisDia : dialogue){
	if curDia==thisDia{
		diaStep+=1
	}else{
		diaStep=0
		curDia=thisDia
	}
	if diaStep==4 || curDia.words[diaStep]==""{
		curDia.update^ = true
		curDia=defaultDialogue
		diaStep=0
	}
}

updateDiaPos :: proc(sock : sock, dia : ^dialogue){
	dia^.x = i32(sock.position.x + sock.sockbox.x)
	dia^.y = i32(sock.position.y)
}

sockTexture : rl.Texture
stageTexture : rl.Texture
kingSockTexture : rl.Texture
dinoTexture : rl.Texture
pirateTexture : rl.Texture
mountainTexture : rl.Texture
cheeseTexture : rl.Texture
eventsTexture : rl.Texture
thechoosingTexture : rl.Texture
thanksyou : rl.Texture

kingsock : sock
dinosock : sock
piratesock : sock
mountain : sock
curEv : events
acceptedQuest:bool

quest:dialogue
kingImpatient:dialogue
kingOuch:dialogue
dinoIntroduced : bool
dinoIntroLock : bool
dinoIntro:dialogue
dinoAttackMode : bool
dinoDia:dialogue
dinoHP : int
dinoOuch:dialogue
pirateIntroduced : bool
pirateIntro:dialogue
riddling:bool
riddleCorrect:bool
pirateRiddle:dialogue
pirateIncorrect:dialogue
thatsnotaletter:dialogue
donePirate:bool
pirateCorrect:dialogue
mountainIntroduced:bool
mountainIntro:dialogue
thechoosing:bool
chosen:bool
chooseDialogue:dialogue
kingWin:dialogue
dinoWin:dialogue
pirateWin:dialogue
stealWin:dialogue
lastMouseDir:i8
progress:int
mpos : rl.Vector2
init :: proc(){
	//rl.HideCursor()
	rl.InitWindow(800, 450, "a rather silly tale of sock puppets")
	sockTexture = rl.LoadTexture("assets/sock.png")
	stageTexture =rl.LoadTexture("assets/stage.png")
	kingSockTexture =rl.LoadTexture("assets/kingsock.png")
	dinoTexture =rl.LoadTexture("assets/dino.png")
	pirateTexture =rl.LoadTexture("assets/pirate.png")
	mountainTexture =rl.LoadTexture("assets/mountain.png")
	cheeseTexture =rl.LoadTexture("assets/cheese.png")
	eventsTexture =rl.LoadTexture("assets/events.png")
	thechoosingTexture =rl.LoadTexture("assets/thechoosing.png")
	thanksyou =rl.LoadTexture("assets/thanksyou.png")
	kingsock =sock{{150,175},{120,190},{240,190},&kingSockTexture}
	dinosock =sock{
		{150,400},//goes to 150 175
		{120,190},
		{240,190},
		&dinoTexture,
	}
	piratesock =sock{
		{150,-190},//goes to 150 175
		{120,190},
		{240,190},
		&pirateTexture,
	}
	mountain =sock{
		{220,450},//goes to 220 138
		{360,240},
		{360,240},
		&mountainTexture,
	}
	//storyUpdates
	acceptedQuest =false
	quest ={i32(kingsock.position.x)+i32(kingsock.sockbox.x),i32(kingsock.position.y),
		{"hello mr sock","i have a quest for you","go to the mountain...","and get the cheese"},&acceptedQuest}
	kingImpatient ={i32(kingsock.position.x)+i32(kingsock.sockbox.x),i32(kingsock.position.y),
		{"did you go yet???","...","nothing is happening here","..."},&acceptNA}
	kingOuch ={i32(kingsock.position.x)+i32(kingsock.sockbox.x),i32(kingsock.position.y),
		{"OUCH!!!","THAT HURT!!!","",""},&acceptNA}
	dinoIntroduced =false
	dinoIntroLock =false
	dinoIntro ={i32(dinosock.position.x)+i32(dinosock.sockbox.x),i32(dinosock.position.y),
		{"rawr!","","",""},&dinoIntroduced}
	dinoAttackMode =false
	dinoDia ={150+120,175,//raaar = love, ror = cheese, rar = is/at, rowr = good, rawr = dino/greeting/interjection, rrrr=now, RAAWR=play, if doubling a noun that makes it accusative, if doubling an adjective it strengthens adjective
		{"raaar ror ror","ror rar rowr","ror rowr rowr rar rawr rawr?","rrrr RAAWR"},&dinoAttackMode}
	dinoHP =6
	dinoOuch ={150+120,175,
		{"ROOAAR!!!","","",""},&dinoAttackMode}
	pirateIntroduced=false
	pirateIntro ={150+120,175,
	{"yo ho ho","im a pirate","who be dis...","a landlubber???"},&pirateIntroduced}
	riddling=false
	riddleCorrect=false
	pirateRiddle={150+120,175,
		{"i like riddles and cheese","but i dont have any cheese...","so you must ANSWER MY RIDDLE","what is my favorite letter?"},&riddling}
	pirateIncorrect ={150+120,175,
		{"YOURE WRONG","TRY AGAIN","",""},&acceptNA}
	thatsnotaletter ={150+120,175,
		{"ummm thats not a letter","","",""},&acceptNA}
	donePirate=false
	pirateCorrect ={150+120,175,
		{"GOOD JOB","you can pass","(and i need to find some cheese...)",""},&donePirate}
	mountainIntroduced =false
	mountainIntro ={230,100,
		{"you is want cheese?","i has much goat so is much cheese","heer is cheese fren","bye bye"},&mountainIntroduced}
	thechoosing=false
	chosen=false
	chooseDialogue ={146,100,
		{"now you choose who gets the cheese","choose wisely","(use numbers 1-4)",""},&thechoosing}
	kingWin ={146,100,
		{"you give the cheese to the king","'yippee, thank you very much sock'","thanks for playing my game!","the end"},&acceptNA}
	dinoWin ={146,100,
		{"you give the cheese to the dino","'RAWR! :) raaar ror ror rowr rowr'","thanks for playing my game!","the end"},&acceptNA}
	pirateWin ={146,100,
		{"you give the cheese to the pirate","'yarrr! thank you very much landlubber!'","thanks for playing my game!","the end"},&acceptNA}
	stealWin ={146,100,
		{"you STEAL the cheese!","'cheese is yummy and im very greedy'","thanks for playing my game!","the end"},&acceptNA}
	//{"beans","","",""}}
	//currentDialogue = quest
	rl.SetTargetFPS(30)
	lastMouseDir =1
	curEv =events.king
	progress =0
	mpos={0,0}
}
	update :: proc(){
		log.infof("mousepos: {}",mpos)
	mpos = rl.GetMousePosition()	
	sockpos:rl.Vector2={mpos.x-60,mpos.y-50}
		//curEv=events(int(curEv)+int(rl.GetMouseWheelMove()))	
		if curEv==events.picking{
			if rl.IsMouseButtonPressed(rl.MouseButton.LEFT){
				if progress==1{
					curEv=events.dinosaur
				}
				if progress==2{
					curEv=events.pirates
				}
				if progress==3{
					curEv=events.mountain
				}
				if progress==4{
					curEv=events.choose
				}
			}
		}
		if curEv==events.king{
			if rl.Vector2Length(rl.GetMouseDelta())>150 && rl.CheckCollisionPointRec(mpos,{kingsock.position.x,kingsock.position.y,kingsock.sockbox.x,kingsock.sockbox.y}){
				diaSys(kingOuch)
			}
			if acceptedQuest==true && kingsock.position.x>-150{
				kingsock.position.x-=2
			}
			if kingsock.position.x<0{
				curEv=events.picking
				progress=1
			}
			if rl.IsMouseButtonPressed(rl.MouseButton.LEFT){
				if rl.CheckCollisionPointRec(mpos,{kingsock.position.x,kingsock.position.y,kingsock.talkbox.x,kingsock.talkbox.y}){
					if acceptedQuest==false{
						diaSys(quest)
					}
				}
			}
		}
		if curEv==events.dinosaur{
			if dinosock.position.y>175 && dinoIntroduced==false{
				dinosock.position.y-=1
			}else{
					if dinoIntroLock==false{
						updateDiaPos(dinosock,&dinoIntro)
						diaSys(dinoIntro)
						dinoIntroLock=true					
					}

				if dinoAttackMode==false && rl.IsMouseButtonPressed(rl.MouseButton.LEFT) && rl.CheckCollisionPointRec(mpos,{dinosock.position.x,dinosock.position.y,dinosock.talkbox.x,dinosock.talkbox.y}){
					if dinoIntroduced==false{
						diaSys(dinoIntro)
					}else{
						diaSys(dinoDia)
					}
				}
			if dinoAttackMode==true && dinoHP>0{
					dinosock.position+= 3*rl.Vector2Normalize(sockpos-dinosock.position)
				}
			if dinoHP>0&&rl.Vector2Length(rl.GetMouseDelta())>150 && rl.CheckCollisionPointRec(mpos,{dinosock.position.x,dinosock.position.y,dinosock.sockbox.x,dinosock.sockbox.y}){
				diaSys(dinoOuch)
				if dinoAttackMode==true{
						dinoHP-=1
					}
			}
			if dinoHP<=0{
					dinosock.position.y+=2
					if dinosock.position.y>=400{
						curEv=events.picking
						progress=2
					}
				}
			

			}
		}
		
		if curEv==events.pirates{
			if piratesock.position.y<175&&donePirate==false{
				piratesock.position.y+=3
			}
			if piratesock.position.y>-190&&donePirate==true{
				piratesock.position.y-=3
			}
			if piratesock.position.y<=-190&&donePirate==true{
				curEv=events.picking
				progress=3
			}
			if riddling{
				if rl.IsKeyPressed(rl.KeyboardKey.R){
					diaSys(pirateCorrect)
					riddleCorrect=true
				}else if rl.GetKeyPressed()!=nil{
					diaSys(pirateIncorrect)
				}
			}
			if rl.IsMouseButtonPressed(rl.MouseButton.LEFT)&&rl.CheckCollisionPointRec(mpos,{piratesock.position.x,piratesock.position.y,piratesock.talkbox.x,piratesock.talkbox.y}){
				if pirateIntroduced==false{
					diaSys(pirateIntro)
				}else if riddling{
					if riddleCorrect{
					diaSys(pirateCorrect)
					}else{
						diaSys(thatsnotaletter)
					}
				}else{
					diaSys(pirateRiddle)
				}
			}
		}
		if curEv==events.mountain{
			if mountain.position.y>138&&mountainIntroduced==false{
				mountain.position.y-=2
			}
			if mountainIntroduced==false&&rl.IsMouseButtonPressed(rl.MouseButton.LEFT) && rl.CheckCollisionPointRec(mpos,{mountain.position.x,mountain.position.y,mountain.talkbox.x,mountain.talkbox.y}){
				diaSys(mountainIntro)
			}
			if mountainIntroduced==true&&mountain.position.y<=450{
				mountain.position.y+=2
			}
			if mountainIntroduced==true&&mountain.position.y>450{
				curEv=events.picking
				progress=4
			}
		}
		if curEv==events.choose{
			if chosen==false&&thechoosing==false&&rl.IsMouseButtonPressed(rl.MouseButton.LEFT){
				diaSys(chooseDialogue)
			}
			if thechoosing{
				if rl.IsKeyPressed(rl.KeyboardKey.ONE){
					diaSys(kingWin)
					chosen=true
					diaStep=0
					thechoosing=false
				}
				if rl.IsKeyPressed(rl.KeyboardKey.TWO){
					diaSys(dinoWin)
					chosen=true
					diaStep=0
					thechoosing=false
				}
				if rl.IsKeyPressed(rl.KeyboardKey.THREE){
					diaSys(pirateWin)
					chosen=true
					diaStep=0
					thechoosing=false
				}
				if rl.IsKeyPressed(rl.KeyboardKey.FOUR){
					diaSys(stealWin)
					chosen=true
					diaStep=0
					thechoosing=false
				}
			}
				if chosen==true&&rl.IsMouseButtonPressed(rl.MouseButton.LEFT){
					diaStep+=1
					if diaStep==4{
						curDia=defaultDialogue
						diaStep=0
						curEv=events.thanksyou
					}
				}
		}

		if rl.GetMouseDelta().x>0{
			lastMouseDir = 1
		}
		if rl.GetMouseDelta().x<0{
			lastMouseDir = -1
		}
		rl.BeginDrawing()
		rl.ClearBackground(rl.Color{71,14,0,255})
		if curEv==events.choose{
			rl.DrawTexture(thechoosingTexture,146,118,rl.WHITE)
		}
		if curEv==events.mountain{
			rl.DrawTextureV(mountainTexture,mountain.position,rl.WHITE)
		}
		if curEv==events.thanksyou{
			rl.DrawTexture(thanksyou,146,118,rl.WHITE)
		}
		rl.DrawRectangle(rl.GetMouseX(),i32(sockpos.y)-300,10,400,rl.Color{220,203,157,255})
		rl.DrawTextureRec(sockTexture,{0,0,120*f32(lastMouseDir),190},sockpos,rl.WHITE)
		//rl.DrawRectangleRec(rectangle, rl.Color{255,255,0,255})
		if curEv==events.king{
			rl.DrawTextureV(kingsock.texture^,kingsock.position,rl.WHITE)
		}
		if curEv==events.dinosaur{
			rl.DrawTextureV(dinosock.texture^,dinosock.position,rl.WHITE)	
		}
		if curEv==events.pirates{
			rl.DrawTextureV(pirateTexture, piratesock.position, rl.WHITE)
		}
		if curEv==events.mountain && mountainIntroduced{
			rl.DrawTexture(cheeseTexture,340,130,rl.WHITE)
		}
		rl.DrawTexture(stageTexture,0,0,rl.WHITE)
		if curEv==events.picking{
		rl.DrawTexture(eventsTexture,183,374,rl.WHITE)
		}
		if curDia.words[diaStep]!=defaultDialogue.words{
			rl.DrawRectangle(curDia.x-5,curDia.y,rl.MeasureText(curDia.words[diaStep],30)+10,35,rl.WHITE)
			rl.DrawText(curDia.words[diaStep],curDia.x,curDia.y,30,rl.BLACK)
		}
		//rl.DrawText(rl.TextFormat("debug:%f",mountain.position.y),10,10,30,rl.GREEN)
		//rl.DrawFPS(10,10)
		rl.EndDrawing()
	free_all(context.temp_allocator)
	}

parent_window_size_changed :: proc(w,h :int){

}

shutdown :: proc() {
	rl.CloseWindow()
}

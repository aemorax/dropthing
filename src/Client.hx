package;

#if js

import core.RoomData;
import core.ServerMessage;
import core.JoinData;
import haxe.Json;
import hxd.res.Embed;
import hxd.res.FontBuilder;
import h2d.Font;
import h2d.Text;
import js.html.MessageEvent;
import js.html.WebSocket;
import h2d.Object;
import h2d.Interactive;
import h3d.Vector;
import h2d.Bitmap;
import h2d.Tile;

class Client extends hxd.App {
	var server : String = "ws://localhost:8000";
	var socket : WebSocket;
	var playerID : Int;

	var mainMenu : Object;
	var waitScene : Object;

	var waitingText : Text;

	var atlas : Tile;
	var font20 : Font;
	var p1Turn : Bool = true;
	var board : Tile;
	var piece : Tile;

	var pices : Object;
	
	var row1 : Interactive;
	var row2 : Interactive;
	var row3 : Interactive;
	var row4 : Interactive;
	var row5 : Interactive;

	var m : Array<Int> = new Array<Int>();

	static final COLOR_RED:Vector =new Vector(229/255, 53/255, 44/255, 1);
	static final Color_ORANGE:Vector = new Vector(229/255, 123/255, 42/255, 1);
	static final Color_YELLOW:Vector = new Vector(229/255, 194/255, 42/255, 1);
	static final Color_GREEN:Vector = new Vector(148/255, 229/255, 42/255, 1);
	static final Color_TIEL:Vector = new Vector(42/255, 229/255, 201/255, 1);
	static final Color_BLUE:Vector = new Vector(42/255, 138/255, 229/255, 1);
	static final COLOR_PURPLE:Vector = new Vector(70/255, 43/255, 78/255, 1);

	function loadAtlas() {
		atlas = hxd.Res.boardandpiece.toTile();
		var fontBuildOpt : FontBuildOptions = {
			antiAliasing: false
		};
		font20 = FontBuilder.getFont("R_res_evilempire_ttf", 24, fontBuildOpt);
	}

	override function init() : Void {
		engine.backgroundColor = 0xff393b45;
		s2d.scaleMode = ScaleMode.LetterBox(175,148);
		loadAtlas();

		createMainMenu();
		createWaitScene();
		s2d.addChild(mainMenu);

		for(i in -9...1)
			trace(Math.abs(i));


		/*
		drawField();
		createNewModel();
		pices = new Object(s2d);
		pices.x = 10;
		pices.y = 20;

		var b = new Bitmap(board, s2d);
		b.x = 10;
		b.y = 20;

		row1 = new Interactive(22, 98, b);
		row2 = new Interactive(22, 98, b);
		row2.x = row1.x + 23;
		row3 = new Interactive(22, 98, b);
		row3.x = row2.x + 23;
		row4 = new Interactive(22, 98, b);
		row4.x = row3.x + 23;
		row5 = new Interactive(22, 98, b);
		row5.x = row4.x + 23;

		row1.onClick = function e(e:hxd.Event) {
			if(p1Turn) {
				if(drop(1, 0) == -1)
					return;
				p1Turn = false;
			} else {
				if(drop(2, 0) == -1)
					return;
				p1Turn = true;
			}
		}

		row2.onClick = function e(e:hxd.Event) {
			if(p1Turn) {
				if(drop(1, 1) == -1)
					return;
				p1Turn = false;
			} else {
				if(drop(2, 1) == -1)
					return;
				p1Turn = true;
			}
		}

		row3.onClick = function e(e:hxd.Event) {
			if(p1Turn) {
				if(drop(1, 2) == -1)
					return;
				p1Turn = false;
			} else {
				if(drop(2, 2) == -1)
					return;
				p1Turn = true;
			}
		}

		row4.onClick = function e(e:hxd.Event) {
			if(p1Turn) {
				if(drop(1, 3) == -1)
					return;
				p1Turn = false;
			} else {
				if(drop(2, 3) == -1)
					return;
				p1Turn = true;
			}
		}
		
		row5.onClick = function e(e:hxd.Event) {
			if(p1Turn) {
				if(drop(1, 4) == -1)
					return;
				p1Turn = false;
			} else {
				if(drop(2, 4) == -1)
					return;
				p1Turn = true;
			}
		}
		*/
	}
	/*
		 __  __           _             __  __                        
		|  \/  |         (_)           |  \/  |                       
		| \  / |   __ _   _   _ __     | \  / |   ___   _ __    _   _ 
		| |\/| |  / _` | | | | '_ \    | |\/| |  / _ \ | '_ \  | | | |
		| |  | | | (_| | | | | | | |   | |  | | |  __/ | | | | | |_| |
		|_|  |_|  \__,_| |_| |_| |_|   |_|  |_|  \___| |_| |_|  \__,_|
	*/

	function createMainMenu() {
		mainMenu = new Object();
		var titleTile = atlas.sub(42, 34, 100, 20);
		var title = new Bitmap(titleTile, mainMenu);
		title.x = 40; title.y = 19;
		var joinButtonTile = atlas.sub(23, 58, 117, 40);
		var joinButton = new Bitmap(joinButtonTile, mainMenu);
		joinButton.color = new Vector(15/255, 164/255, 103/255, 1);
		joinButton.x = 31; joinButton.y = 51;

		var text : Text = new Text(font20, joinButton);
		text.text = "Join";
		text.x = 59 - (text.textWidth/2);
		text.y = 20 - (text.textHeight/2);

		var buttonInteractive : Interactive = new Interactive(117, 40, joinButton);
		buttonInteractive.onOver = function(e:hxd.Event) {
			joinButton.color = new Vector(30/255, 179/255, 118/255, 1);
		};

		buttonInteractive.onOut = function(e:hxd.Event) {
			joinButton.color = new Vector(15/255, 164/255, 103/255, 1);
		};
		
		buttonInteractive.onClick = function(e:hxd.Event) {
			joinMatch();
		}
	}

	/*
		__          __          _   _        _____                              
		\ \        / /         (_) | |      / ____|                             
		 \ \  /\  / /    __ _   _  | |_    | (___     ___    ___   _ __     ___ 
		  \ \/  \/ /    / _` | | | | __|    \___ \   / __|  / _ \ | '_ \   / _ \
		   \  /\  /    | (_| | | | | |_     ____) | | (__  |  __/ | | | | |  __/
			\/  \/      \__,_| |_|  \__|   |_____/   \___|  \___| |_| |_|  \___|																
    */

	function createWaitScene() {
		waitScene = new Object();
		waitingText = new Text(font20, waitScene);
	}

	function joinMatch() {
		trace("connect to server");
		s2d.removeChild(mainMenu);
		s2d.addChild(waitScene);
		waitingText.text = "Connecting To Server...";
		recalculateWaitingTextPos();
		connect();
	}

	function serverMessage(event:MessageEvent) {
		var data : ServerMessage = Json.parse(event.data);
		trace(data);

		var type : ServerMessageType = data.type;
		var t : ServerMessageType = Connected;
		trace(type);
		trace(t);

		switch (type) {
			case Connected:
				waitForOpponent(data);
			case RoomUpdate:
				setRoomData(data);
			case _:
				socket.close();
		}
	}

	function waitForOpponent(data : ServerMessage) {
		trace("waiting for opponent");
		var joinData : JoinData = data.data;
		playerID = joinData.id;
		trace(playerID);
		waitingText.text = "Waiting For Opponent...";
		recalculateWaitingTextPos();
	}

	function setRoomData(data :ServerMessage) {
		var roomData : RoomData = data.data;
		/*
		switch (roomData.roomState) {
			case Ready:

		}
		*/
	}

	function reset() {
		s2d.removeChildren();
		s2d.addChild(mainMenu);	
	}

	function connect() {
		socket = new WebSocket(server);
		socket.addEventListener("message", serverMessage);
		socket.addEventListener("close", reset);
		socket.addEventListener("error", reset);
	}

	function recalculateWaitingTextPos() {
		waitingText.x = 89 - (waitingText.textWidth/2);
		waitingText.y = 70 - (waitingText.textHeight/2);
	}

	function createNewModel() {
		for (i in 0...25) {
			m[i] = 0;
		}
	}

	function drop(p:Int, row:Int) : Int {
		var c : Int = getEmptyColumnOfRow(row);
		trace(c);
		if(c == -1)
			return -1;

		set(c, row, p);

		var p1 = new Bitmap(piece);
		if(p == 1)
			p1.color = COLOR_RED;
		else
			p1.color = Color_BLUE;

		p1.y = 79-(c*19);
		p1.x = (row*22)+3;

		pices.addChild(p1);
		return 0;
	}

	function getEmptyColumnOfRow(row : Int) : Int {
		for (i in 0...5) {
			trace(m[i*5+row]);
			if(m[i*5+row] == 0)
				return i;
		}
		return -1;
	}

	function get(column : Int, row : Int) : Int {
		return this.m[column*5+row];
	}

	function set(column : Int, row : Int, value : Int) {
		this.m[column*5+row] = value;
	}

	function getDiagonals(): Int {
		var a : Int = get(1,0);
		var b : Int = get(2,1);
		var c : Int = get(3,2);
		var d : Int = get(4,3);
		var d1 = a | b | c | d;
		if(d1 == 1)
			return 1;
		else if (d1 == 2)
			return 2;
		
		a = get(0,0);
		b = get(1,1);
		c = get(2,2);
		d = get(3,3);
		d1 = a | b | c | d;
		if(d1 == 1)
			return 1;
		else if(d1 == 2)
			return 2;

		a = get(4,4);
		d1 = a | b | c | d;
		if(d1 == 1)
			return 1;
		else if(d1 == 2)
			return 2;

		a = get(0,1);
		b = get(1,2);
		c = get(2,3);
		d = get(3,4);
		if(d1 == 1)
			return 1;
		else if(d1 == 2)
			return 2;

		return 0;
	}

	function getHorizontals() : Int {
		var a : Int = 0;
		var b : Int = 0;
		var c : Int = 0;
		var d : Int = 0;
		var d1 : Int = 0;

		for(i in 0...5)
		{
			for(j in 0...2) {
				a = get(i, 0+j);
				b = get(i, 1+j);
				c = get(i, 2+j);
				d = get(i, 3+j);
				d1 = a | b | c | d;
				if(d1 == 1)
					return 1;
				else if(d1 == 2)
					return 2;
			}
		}

		return 0;
	}

	function getVerticals() : Int {
		var a : Int = 0;
		var b : Int = 0;
		var c : Int = 0;
		var d : Int = 0;
		var d1: Int = 0;

		for (i in 0...5) {
			for(j in 0...2) {
				a = get(j, i);
				b = get(j+1, i);
				c = get(j+2, i);
				d = get(j+3, i);
				d1 = a | b | c | d;
				if(d1 == 1)
					return 1;
				else if(d1 == 2)
					return 2;
			}
		}

		return 0;
	}

	function checkWinning() : Int {
		var d  = getDiagonals();
		if(d != 0)
			return d;

		d = getHorizontals();
		if(d != 0)
			return d;

		d = getVerticals();
		if(d != 0)
			return d;

		return 0;
	}

	function drawField() : Void {
		var boardAndPiece = hxd.Res.boardandpiece.toTile();
		board = boardAndPiece.sub(0, 0, 110, 98);
		piece = boardAndPiece.sub(110, 0, 16, 16);
	}

	override function update(_) : Void {}

	static function main() {
		Embed.embedFont("res/evilempire.ttf");
		hxd.Res.initEmbed();
		new Client();
	}
}

#end
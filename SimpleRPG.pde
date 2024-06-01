final byte OVERWORLD = 1; //<>//
final byte PLAYERMENU = 2;
final byte BATTLE = 3;

byte direction = 1;
byte gameState = OVERWORLD;
boolean pressed = false;
boolean stillPressed = false;
int gridSize = 10; //Circle size will scale to size of grid, left number is desired grid size(Only even numbers work)
int pauseTimer = 0;
ArrayList<Level> allLevels = new ArrayList<Level>();

EnemySet allEnemies;
ItemSet allItems;
Level test;
Player player = new Player(350, 350, byte(0), byte(0));
Pointer pointer  = new Pointer(330, 630);
PlayerMenu pause;
BattleMenu battle;
TileSet allTiles;



void setup() {
  size(1000, 1000); // size of window can't because having to deal with that is too annoying and hard
  background(0);
  frameRate(60);
  allItems = new ItemSet();
  allEnemies = new EnemySet();
  allTiles = new TileSet();
  allLevels.add(new Level("testlevel.txt"));
  pause = new PlayerMenu();
  battle = new BattleMenu();
  player.changeWeapon(new Item("none", byte(1)));
  player.changeHelmet(new Item("none", byte(1)));
  player.changeArmor(new Item("none", byte(1)));
  player.changeShield(new Item("none", byte(1)));

  allLevels.get(0).drawMap(0, 0);
  player.drawPlayer();

  for (int i = 0; i < 10; i++) {
    player.addItem("Herb", byte(i));
  }

  player.addItem("Pot Lid", 1);
  player.addItem("Pot", 1);
  player.addItem("Rusted Sword", 1);
  player.addItem("Thick Jacket", 1);
  println(player.getInventory().getItems().size());
}






public class Map {
    Tile[][] mapTiles = new Tile[gridSize][gridSize];
    int red;
    int blue;
    int green;
    PImage bgTexture;
  
    public Map(String map, int r, int g, int b, String bg) {
      red = r;
      green = g;
      blue = b;
      bgTexture = allTiles.getTileType(bg).getTexture();
  
      String[] lines = loadStrings(map);
      //println(map);
  
      for (int i = 0; i < lines.length; i++) {
        String[] tiles = trim(splitTokens(lines[i], "| ,"));
        //println(lines[i]);
        //println("i is " + i);
        //println(tiles.length);
  
        for (int h = 0; h < tiles.length; h += 3) {
          //drawTile(h * 2 + 1, i * 2 + 1, tiles[h]);
          //println("h is " + h);
          //println("h is " + tiles[h]);
          mapTiles[h / 3][i] = new Tile(tiles[h], (h / 3), i, tiles[h + 1], Byte.valueOf(tiles[h + 2]));
        }
      }
    }
  
    public void drawMap() {
      background(red, green, blue);
  
      for (int i = 0; i < gridSize; i++) {
        for (int h = 0; h < gridSize; h++) {
          image(bgTexture, h * 100, i * 100);
        }
      }
  
      for (int i = 0; i < mapTiles.length; i++) {
        ////println("Column size is" + mapTiles.length);
        for (int h = 0; h < mapTiles[i].length; h++) {
          ////println("Row size is" + mapTiles[i].length);
          //println("drawing X:" + h + " Y: " + i);
          //println("drawing " + mapTiles[h][i].getName());
          mapTiles[h][i].drawTile();
        }
      }
    }
  
    public Tile getTile(int x, int y) {
      return(mapTiles[(x - 50) / 100][(y - 50) / 100]);
    }
    
    
}



public class Level {
    Map[][] levelAreas = new Map[gridSize][gridSize];
  
  
    public Level(String level) {
  
      String[] lines = loadStrings(level);
  
      for (int i = 0; i < lines.length; i++) {
        String[] maps = trim(split(lines[i], ","));
        ////println("i is " + i);
  
        for (int h = 0; h < maps.length; h++) {
          //drawTile(h * 2 + 1, i * 2 + 1, tiles[h]);
          ////println("h is " + h);
  
          levelAreas[i][h] = new Map(maps[h], 0, 255, 0, "grass");
        }
      }
    }
  
    public void drawMap (int x, int y) {
      levelAreas[x][y].drawMap();
    }
  
    public Map getMap(int x, int y) {
      return(levelAreas[x][y]);
    }
    
    
}



public class Player {
  int atk = 3;
  int def = 1;
  int gold = 0;
  int hp = 1;
  int nextExp = 20;
  int maxHP = 20;
  int maxMP = 10;
  int mp = 10;
  int posX;
  int posY;
  int newPosX;
  int newPosY;
  int statLevel = 1;
  byte level = 0;
  byte levelX;
  byte levelY;
  byte movePercent = 0;
  boolean defending = false;
  boolean moving = false;
  Inventory inventory = new Inventory();
  Item helmet;
  Item armor;
  Item weapon;
  Item shield;

  public Player(int x, int y, byte lX, byte lY) {
    posX = x;
    posY = y;
    newPosX = x;
    newPosY = y;
    levelX = lX;
    levelY = lY;
  }

  public void addItem(String n, int a) {
    inventory.addItem(n, byte(a));
  }

  public void drawPlayer() {
    fill(0, 255, 0);
    stroke(0);
    strokeWeight(1);
    strokeJoin(MITER);

    switch(direction) {
    case 1:
      triangle((posX), (posY) - 25, (posX) + 25, (posY) + 25, (posX) - 25, (posY) + 25);
      break;

    case 2:
      triangle((posX) + 25, (posY), (posX) - 25, (posY) + 25, (posX) - 25, (posY) - 25);
      break;

    case 3:
      triangle((posX), (posY) + 25, (posX) + 25, (posY) - 25, (posX) - 25, (posY) - 25);
      break;

    case 4:
      triangle((posX) - 25, (posY), (posX) + 25, (posY) + 25, (posX) + 25, (posY) - 25);
      break;
    }
  }

  public Item changeArmor(Item i) {
    Item old = armor;
    armor = i;

    return(old);
  }

  public void changeHelmet(Item i) {
    helmet = i;
  }


  public void changeHP(int h) {
    hp += h;

    if (hp > maxHP) {
      hp = maxHP;
    }
  }

  public void changeShield(Item i) {
    shield = i;
  }

  public void changeWeapon(Item i) {
    weapon = i;
  }

  public Item getArmor() {
    return(armor);
  }


  public int getAtk() {
    return(atk);
  }

  public int getAtkArmor() {
    return(armor.getAtk());
  }

  public int getAtkHelmet() {
    return(helmet.getAtk());
  }

  public int getAtkShield() {
    return(shield.getAtk());
  }

  public int getAtkWeapon() {
    return(weapon.getAtk());
  }


  public byte getCurrentLevel() {
    return(level);
  }

  public int getDef() {
    return(def);
  }
  
  public boolean getDefending(){
    return(defending); 
    
  }  

  public int getDefArmor() {
    return(armor.getDef());
  }

  public int getDefHelmet() {
    return(helmet.getDef());
  }

  public int getDefShield() {
    return(shield.getDef());
  }

  public int getDefWeapon() {
    return(weapon.getDef());
  }

  public int getExp() {
    return(nextExp);
  }

  public int getGold() {
    return(gold);
  }

  public Item getHelmet() {
    return(helmet);
  }

  public int getHP() {
    return(hp);
  }

  public Inventory getInventory() {
    return(inventory);
  }

  public byte getLevelX() {
    return(levelX);
  }

  public byte getLevelY() {
    return(levelY);
  }

  public int getMaxHP() {
    return(maxHP);
  }

  public int getMaxMP() {
    return(maxMP);
  }

  public int getMP() {
    return(mp);
  }

  public int getPosX() {
    return(posX);
  }

  public int getPosY() {
    return(posY);
  }

  public Item getShield() {
    return(shield);
  }

  public int getStatLevel() {
    return(statLevel);
  }

  public int getTotalAtk() {
    return(player.getAtk() + player.getAtkArmor() + player.getAtkShield() + player.getAtkHelmet() + player.getAtkWeapon());
  }

  public int getTotalDef() {
    return(player.getDef() + player.getDefArmor() + player.getDefShield() + player.getDefHelmet() + player.getDefWeapon());
  }


  public Item getWeapon() {
    return(weapon);
  }

  public void giveExp(int e) {
    nextExp -= e;

    while (nextExp <= 0) {
      levelUp(nextExp);
    }
  }
  
  public int hurt(int d){ //damage player health and return the damage number
    int damage = d - getTotalDef();
    
    if(defending){
      damage = d - int((getTotalDef() * 1.25));
      
    }  
    
    if (damage < 0){
      damage = 0;
      
    }  
    
    return(damage);
    
  }  

  public void inBounds() {
    if (player.getPosX() > 1000) {
      player.teleportPlayer(50, player.getPosY(), byte(player.getLevelX() + 1), player.getLevelY());
      background(0);
      pauseTimer = 11;
    }

    if (player.getPosX() < 0) {
      player.teleportPlayer(950, player.getPosY(), byte(player.getLevelX() - 1), player.getLevelY());
      background(0);
      pauseTimer = 11;
    }

    if (player.getPosY() > 1000) {
      player.teleportPlayer(player.getPosX(), 50, player.getLevelX(), byte(player.getLevelY() + 1));
      background(0);
      pauseTimer = 11;
    }

    if (player.getPosY() < 0) {
      player.teleportPlayer(player.getPosX(), 950, player.getLevelX(), byte(player.getLevelY() - 1));
      background(0);
      pauseTimer = 11;
    }
  }



  public boolean inMovement() {
    return(moving);
  }

  public void levelUp(int e) {
    nextExp = (statLevel + (statLevel + 1)) * 20;
    nextExp += e;
    statLevel += 1;
    println(statLevel);


    float hpPerc = float(hp) / float(maxHP);
    float mpPerc = float(mp) / float(maxMP);

    //println(hpPerc);
    //println(mpPerc);

    atk += 2;
    def += 1;
    maxHP += 20;
    maxMP += 10;

    hp = Math.round(maxHP * hpPerc);
    mp = Math.round(maxMP * mpPerc);
  }


  public void moveAnimation() {
    float moveX = posX;
    float moveY = posY;

    if (moving) {
      movePercent += 10;

      if (newPosX > posX) {
        moveX += movePercent;
      } else if (newPosX < posX) {
        moveX -= movePercent;
      }

      if (newPosY > posY) {
        moveY += movePercent;
      } else if ( newPosY < posY) {
        moveY -= movePercent;
      }

      switch(direction) {
      case 1:
        triangle(moveX, moveY - 25, moveX + 25, moveY + 25, moveX - 25, moveY + 25);
        break;

      case 2:
        triangle(moveX + 25, moveY, moveX - 25, moveY + 25, moveX - 25, moveY - 25);
        break;

      case 3:
        triangle(moveX, moveY + 25, moveX + 25, moveY - 25, moveX - 25, moveY - 25);
        break;

      case 4:
        triangle(moveX - 25, moveY, moveX + 25, moveY + 25, moveX + 25, moveY - 25);
        break;
      }

      //println("moveX " + moveX);
      //println("moveY " + moveY);


      if (movePercent == 100) {
        moving = false;
        movePercent = 0;
        posX = newPosX;
        posY = newPosY;
      }
    }
  }

  public void movePlayer(int xChange, int yChange) {
    moving = true;
    newPosX += xChange;
    newPosY += yChange;

    //println("posX" + posX);
    //println("posY" + posY);

    //println(moving);
  }
  
  public void setDefending(boolean d){
    defending = d;   
    
  }  

  public void teleportPlayer(int x, int y, byte lX, byte lY) {
    posX = x;
    posY = y;
    newPosX = x;
    newPosY = y;
    levelX = lX;
    levelY = lY;
  }

  public boolean willCollide(byte x, byte y) {
    boolean colliding;
    int nextX = posX + x;
    int nextY = posY + y;

    if (nextX < 0 || nextX > 1000 || nextY < 0 || nextY > 1000) {
      colliding = false;
    } else {
      colliding = allLevels.get(level).getMap(levelX, levelY).getTile(posX + x, posY + y).isSolid();
    }

    return(colliding);
  }
}



class TileType {
  String name = "";
  boolean solid;
  PImage texture;

  public TileType(String n, boolean s, PImage t) {
    name = n;
    solid = s;
    texture = t;
  }

  public String getName() {
    return(name);
  }

  public PImage getTexture() {
    return(texture);
  }

  public boolean isSolid() {
    return(solid);
  }
}



public class Tile extends TileType {
  int posX;
  int posY;
  Item loot;

  public Tile(String n, int x, int y, String l, byte a) {
    super(n, allTiles.getTileType(n).isSolid(), allTiles.getTileType(n).getTexture());
    posX = x;
    posY = y;
    loot = new Item(l, a);
  }

  public void drawTile() {
    image(this.getTexture(), posX * 100, posY * 100);
  }
}

public class TileSet {

  ArrayList<TileType> tiles = new ArrayList<TileType>();

  public TileSet() {
    tiles.add(tiles.size(), new TileType("empty", false, loadImage("empty.png")));

    tiles.add(new TileType("rock", true, loadImage("rock.png")));

    tiles.add(new TileType("rockWall", true, loadImage("rockWall.png")));

    tiles.add(new TileType("grass", false, loadImage("grass.png")));
  }

  public TileType getTileType(String n) {
    for (int i = 0; i < tiles.size(); i++) {
      //println(n + "comparing to" + tiles.get(i).getName());
      if (n.equals(tiles.get(i).getName())) {
        return(tiles.get(i));
      }
    }

    return(tiles.get(0));
  }
}



public void game() {
  allLevels.get(player.getCurrentLevel()).drawMap(player.getLevelX(), player.getLevelY());

  if (!player.inMovement()) {
    //println("this should't be running");
    player.drawPlayer();
    //println("player is still");

    pressed = keyPressed;
    keyPressed();
    //println(key);

    if (pressed) {
      input();
    }

    player.inBounds();
  } else {
    player.moveAnimation();
    //println("player is in motion");
  }




  key = '0';
  //println(key);

  if (keyPressed) {
    stillPressed = true;
  } else {
    stillPressed = false;
  }
}



public void toggleMenu() {

  if (gameState == OVERWORLD) {
    fill(0);
    rect(0, 0, 1000, 1000);
    pause.findEquipment();
    gameState = PLAYERMENU;
    //println("changed to " + gameState);
  } else if (gameState == PLAYERMENU) {
    fill(0);
    rect(0, 0, 1000, 1000);
    gameState = OVERWORLD;
    //println("changed to " + gameState);
  }
}





public void input() {
  //println("in input: " + pressed);
  //println("in input: " + stillPressed);


  if (pressed && !stillPressed) {
    switch(gameState) {
    case 1: //OVERWORLD

      switch(key) {
      case 'w':
        direction = 1;

        if (!player.willCollide(byte(0), byte(-100))) {
          player.movePlayer(0, -100);
        }

        pressed = false;
        key = '0';
        break;

      case 'd':
        direction = 2;

        if (!player.willCollide(byte(100), byte(0))) {
          player.movePlayer(100, 0);
        }

        pressed = false;
        key = '0';
        break;

      case 's':
        direction = 3;

        if (!player.willCollide(byte(0), byte(100))) {
          player.movePlayer(0, 100);
        }

        pressed = false;
        key = '0';
        //println(key);
        break;

      case 'a':
        direction = 4;

        if (!player.willCollide(byte(-100), byte(0))) {
          player.movePlayer(-100, 0);
        }

        pressed = false;
        key = '0';
        break;

      case 'i':
        direction = 1;
        break;

      case 'l':
        direction = 2;
        break;

      case 'k':
        direction = 3;
        break;

      case 'j':
        direction = 4;
        break;

      case 'e':
        toggleMenu();
        //println("menu toggled");
        pointer.setState(1);
        pressed = false;
        key = '0';
        //println(key);
        break;

      case '=':
        player.giveExp(100000);
        break;

      case 'b':
        if (!(gameState == BATTLE)) {
          gameState = BATTLE;
        } else {
          gameState = OVERWORLD;
          
        }

        break;
      }

      break;

    case 2: //PAUSE MENU

      switch(key) {
      case 'w':
        pointer.changeState(-1);



        pressed = false;
        key = '0';
        break;

      case 'd':
        pause.changePage(1);
        pressed = false;
        key = '0';
        break;

      case 's':
        pointer.changeState(1);
        pressed = false;
        key = '0';
        //println(key);
        break;

      case 'a':
        pause.changePage(-1);
        pressed = false;
        key = '0';
        break;

      case 'i':

        break;

      case 'l':

        break;

      case 'k':

        break;

      case 'j':

        break;

      case 'e':
        if (pause.getState() == 1) {
          toggleMenu();
        } else {
          pointer.setState(1);
          pause.setState(byte(1));
          
        }
        //println("menu toggled");
        pressed = false;
        key = '0';
        //println(key);
        break;

      case 'q':
        pause.interact();
        //println("menu toggled");
        pressed = false;
        key = '0';
        //println(key);
        break;

      case 'b':
        if (!(gameState == BATTLE)) {
          gameState = BATTLE;
        } else {
          gameState = OVERWORLD;
        }
        break;
      }
      break;
    case 3: //Battle Screen

      switch(key) {
      case 'w':
        pointer.changeState(-1);



        pressed = false;
        key = '0';
        break;

      case 'd':
        pointer.changeState(2);
        pressed = false;
        key = '0';
        break;

      case 's':
        pointer.changeState(1);
        pressed = false;
        key = '0';
        //println(key);
        break;

      case 'a':
        pointer.changeState(-2);
        pressed = false;
        key = '0';
        break;

      case 'i':

        break;

      case 'l':

        break;

      case 'k':

        break;

      case 'j':

        break;

      case 'e':

        //println("menu toggled");
        pressed = false;
        key = '0';
        //println(key);
        break;

      case 'q':
        battle.interact();
        //println("menu toggled");
        pressed = false;
        key = '0';
        //println(key);
        break;

      case 'b':
        if (!(gameState == BATTLE)) {
          gameState = BATTLE;
        } else {
          gameState = OVERWORLD;
        }

        break;
      }
    }
  }
}

/*if(isBackwards()){
 direction = prevDirection;
 
 }*/





/**********************************************************************************
 ********************************GAME STATE 2*****************************************************************************
 **********************************************************************************/
public class Inventory {
  ArrayList<Item> items = new ArrayList<Item>();

  public Inventory() {
  }

  public void addItem(String s, byte a) {
    Item item = new Item(s, a);

    if (canMerge(item)) {
      mergeStack(item);
    } else {
      items.add(item);
    }
  }

  public boolean canMerge(Item item) {
    for (int i = 0; i < items.size(); i++) {
      if (item.getName().equals(items.get(i).getName()) && items.get(i).getAmount() < items.get(i).getMaxAmount()) {
        return(true);
      }
    }

    return(false);
  }

  public ArrayList<Item> getItems() {
    return(items);
  }

  public void mergeStack(Item item) {
    byte difference = item.getAmount();
    for (int i = 0; i < items.size(); i++) {
      if (item.getName().equals(items.get(i).getName()) && items.get(i).getAmount() < items.get(i).getMaxAmount()) {

        if (items.get(i).getAmount() + difference <= items.get(i).getMaxAmount()) {
          items.get(i).changeAmount(difference);
          item.changeAmount(-difference);
        } else {
          byte leftOver = byte((items.get(i).getAmount() + item.getAmount()) - items.get(i).getMaxAmount());
          items.get(i).changeAmount(item.getAmount()-leftOver);
          item.setAmount(leftOver);
        }

        if (item.getAmount() == 0) {
          break;
        }
      }
    }

    if (item.getAmount() > 0) {
      items.add(item);
    }
  }
}



public class ItemType {
  byte maxAmount;
  int atk;
  int def;
  int gold;
  int hp;
  String category;
  String name;

  public ItemType(String n, String c, byte mA, int a, int d, int h, int g) {
    name = n;
    category = c;
    maxAmount = mA;
    atk = a;
    def = d;
    hp = h;
    gold = g;
  }

  public String getName() {
    return(name);
  }

  public String getCategory() {
    return(category);
  }

  public int getAtk() {
    return(atk);
  }

  public int getDef() {
    return(def);
  }

  public int getGold() {
    return(gold);
  }

  public int getHP() {
    return(hp);
  }


  public byte getMaxAmount() {
    return(maxAmount);
  }
}



public class Item extends ItemType {
  byte amount;

  public Item(String n, byte a) {
    super(n, allItems.getItemType(n).getCategory(), allItems.getItemType(n).getMaxAmount(), allItems.getItemType(n).getAtk(), allItems.getItemType(n).getDef(), allItems.getItemType(n).getHP(), allItems.getItemType(n).getGold());
    amount = a;
  }

  public void changeAmount(int a) {
    if (amount + a <= this.getMaxAmount()) {
      amount += byte(a);
    }
  }

  public byte getAmount() {
    return(amount);
  }

  public void setAmount(int a) {
    amount = byte(a);
  }
}



public class ItemSet {
  ArrayList<ItemType> items = new ArrayList<ItemType>();


  public ItemSet() {
    //Constructor is looking for Name, Category, Max Amount, Atk Stat, Def Stat, HP Stat, Gold Worth)
    items.add(items.size(), new ItemType("none", "none", byte(0), 0, 0, 0, 0));

    items.add(items.size(), new ItemType("Herb", "HEAL", byte(8), 0, 0, 20, 7));

    items.add(items.size(), new ItemType("Pot Lid", "SHIELD", byte(1), 0, 1, 0, 12));

    items.add(items.size(), new ItemType("Thick Jacket", "ARMOR", byte(1), 0, 4, 0, 15));

    items.add(items.size(), new ItemType("Pot", "HELMET", byte(1), 0, 2, 0, 7));

    items.add(items.size(), new ItemType("Rusted Sword", "WEAPON", byte(1), 8, 0, 0, 17));
  }

  public ItemType getItemType(String n) {
    for (int i = 0; i < items.size(); i++) {
      //println(n + "comparing to" + items.get(i).getName());
      if (n.equals(items.get(i).getName())) {
        return(items.get(i));
      }
    }

    return(items.get(0));
  }
}



public class PlayerMenu {
  final byte PAUSE = 1;
  final byte INVENTORY = 2;
  final byte MAGIC = 3;
  final byte EQUIPMENT = 4;

  byte state = PAUSE;
  byte maxPage = 3;
  byte page = 1;
  ArrayList<Item> items = player.getInventory().getItems();
  ArrayList<Item> equipment = new ArrayList<Item>();

    public PlayerMenu() {
    }
  
    public void changePage(int c) {
  
      if ((page + c) < 1) {
        page = maxPage;
      } else if ((page + c) > maxPage) {
        page = byte(1);
      } else {
        page += byte(c);
      }
    }


    public void drawMenu() {
      switch(state) {
          case PAUSE: //PAUSE SCREEN
            stroke(157, 162, 171);
            strokeWeight(20);
            strokeJoin(ROUND);
            fill(0, 0, 255);
            rect(10, 10, 980, 980);
      
            textSize(60);
            textAlign(CENTER);
            fill(0);
      
            text("HP: " + player.getHP(), 155, 152);
            text("/" + player.getMaxHP(), 194, 202);
            text("MP: " + player.getMP(), 155, 302);
            text("/" + player.getMaxMP(), 196, 352);
      
            text("ATK: " + player.getAtk(), 475, 152);
            text("(" + player.getTotalAtk() + ")", 475, 202);
            text("DEF: " + player.getDef(), 475, 302);
            text("(" + player.getTotalDef() + ")", 475, 352);
      
            text("LEVEL: " + player.getStatLevel(), 795, 152);
            text("NEXT LEVEL:", 795, 302);
            text(player.getExp(), 795, 352);
      
            text("Inventory", 505, 652);
            text("Magic", 505, 752);
            text("Equipment", 505, 852);
            text(player.getGold() + " G", 505, 952);
      
            textSize(45);
            text("Weapon: ", 305, 392);
            text(player.getWeapon().getName(), 305, 442);
            text("Armor: ", 305, 512);
            text(player.getArmor().getName(), 305, 562);
            text("Helmet: ", 705, 392);
            text(player.getHelmet().getName(), 705, 442);
            text("Shield: ", 705, 512);
            text(player.getShield().getName(), 705, 562);
      
      
            textSize(60);
            textAlign(CENTER);
            fill(255);
      
            text("HP: " + player.getHP(), 150, 150);
            text("/" + player.getMaxHP(), 189, 200);
            text("MP: " + player.getMP(), 150, 300);
            text("/" + player.getMaxMP(), 191, 350);
      
      
            text("ATK: " + player.getAtk(), 470, 150);
            text("(" + player.getTotalAtk() + ")", 470, 200);
            text("DEF: " + player.getDef(), 470, 300);
            text("(" + player.getTotalDef() + ")", 470, 350);
      
            text("LEVEL: " + player.getStatLevel(), 790, 150);
            text("NEXT LEVEL:", 790, 300);
            text(player.getExp(), 790, 350);
      
            text("Inventory", 500, 650);
            text("Magic", 500, 750);
            text("Equipment", 500, 850);
            text(player.getGold() + " G", 500, 950);
      
            textSize(45);
            text("Weapon: ", 300, 390);
            text(player.getWeapon().getName(), 300, 440);
            text("Armor: ", 300, 510);
            text(player.getArmor().getName(), 300, 560);
            text("Helmet: ", 700, 390);
            text(player.getHelmet().getName(), 700, 440);
            text("Shield: ", 700, 510);
            text(player.getShield().getName(), 700, 560);
      
      
            switch(pointer.getState()) {
                case 1:
                  pointer.teleportPlayer(330, 630, byte(0), byte(0));
                  break;
          
                case 2:
                  pointer.teleportPlayer(380, 730, byte(0), byte(0));
                  break;
          
                case 3:
                  pointer.teleportPlayer(315, 830, byte(0), byte(0));
                  break;
            }
      
      
            pointer.drawPlayer();
      
      
      
            break;
      
      
      
          case INVENTORY:
      
            stroke(157, 162, 171);
            strokeWeight(20);
            strokeJoin(ROUND);
            fill(0, 0, 255);
            rect(10, 10, 980, 980);
      
            textSize(60);
            textAlign(LEFT);
      
      
      
            for (int i = (page - 1) * 10; i < 10 && i < items.size(); i++) {
              fill(0);
              text(items.get(i).getName()+ "       " + items.get(i).getAmount(), 205, i * 90 + 110 + 2);
      
      
              fill(255);
              text(items.get(i).getName()+ "       " + items.get(i).getAmount(), 200, i * 90 + 110);
            }
      
            textAlign(CENTER);
            textSize(40);
            fill(0);
            text("Page " + page, 492, 972);
      
            fill(255);
            text("Page " + page, 487, 970);
      
      
      
      
            pointer.teleportPlayer(135, pointer.getState() * 90, byte(0), byte(0));
      
      
            pointer.drawPlayer();
      
      
            break;
      
          case EQUIPMENT:
      
            stroke(157, 162, 171);
            strokeWeight(20);
            strokeJoin(ROUND);
            fill(0, 0, 255);
            rect(10, 10, 980, 980);
      
            textSize(60);
            textAlign(LEFT);
      
      
      
      
      
            for (int i = (page - 1) * 10; i < 10 && i < equipment.size(); i++) {
              fill(0);
              text(equipment.get(i).getName()+ "       " + equipment.get(i).getAmount(), 205, i * 90 + 110 + 2);
      
      
              fill(255);
              text(equipment.get(i).getName()+ "       " + equipment.get(i).getAmount(), 200, i * 90 + 110);
            }
      
            textAlign(CENTER);
            textSize(40);
            fill(0);
            text("Page " + page, 492, 972);
      
            fill(255);
            text("Page " + page, 487, 970);
      
      
            pointer.teleportPlayer(135, pointer.getState() * 90, byte(0), byte(0));
      
      
            pointer.drawPlayer();
      
      
            break;
      }
  }


  public void equip() {
    if ((pointer.getState() - 1) + ((page - 1) * 10) < equipment.size()) {
      Item item = equipment.get(((pointer.getState() - 1) + ((page - 1) * 10)));

      switch(item.getCategory()) {
          case "WEAPON":
            Item temp1 = player.getWeapon();
            println("equipping" + item.getAtk());
            player.changeWeapon(item);
            println("equipping" + item.getAtk());
    
            if (temp1.getName().equals("none")) {
              println(items.indexOf(temp1));
              items.remove(items.indexOf(item));
            }
    
            println("equipping" + item.getAtk());
            println("equipping" + player.getAtkWeapon());
    
            break;
    
          case "ARMOR":
            Item temp2 = player.getArmor();
            player.changeArmor(item);
    
            if (temp2.getName().equals("none")) {
              println(items.indexOf(temp2));
              items.remove(items.indexOf(item));
            }
    
    
            break;
    
          case "HELMET":
            Item temp3 = player.getHelmet();
            player.changeHelmet(item);
    
            if (temp3.getName().equals("none")) {
              println(items.indexOf(temp3));
              items.remove(items.indexOf(item));
            }
    
    
            break;
    
          case "SHIELD":
            Item temp4 = player.getShield();
            player.changeShield(item);
    
            if (temp4.getName().equals("none")) {
              println(items.indexOf(temp4));
              items.remove(items.indexOf(item));
            }
    
    
            break;
        }
    }
    findEquipment();
    
  }


  public void findEquipment() {
    ArrayList<Item> temp = new ArrayList<Item>();
    for (int i = 0; i < 10 && i < items.size(); i++) {
      if (items.get(i).getCategory().equals("WEAPON") || items.get(i).getCategory().equals("HELMET") || items.get(i).getCategory().equals("ARMOR") || items.get(i).getCategory().equals("SHIELD") ) {
        temp.add(items.get(i));
      }
    }

    equipment = temp;
  }


  public byte getPage() {
    return(page);
  }


  public byte getState() {
    return(state);
  }


  public void interact() {
    switch(state) {
    case PAUSE:

      switch(pointer.getState()) {
      case 1:
        state = INVENTORY;
        pointer.setState(1);
        break;

      case 2:
        state = MAGIC;
        pointer.setState(1);
        break;

      case 3:
        state = EQUIPMENT;
        pointer.setState(1);
        break;
      }

      break;

    case INVENTORY:
      useItem();

      break;

    case EQUIPMENT:
      equip();

      break;
    }
  }


  public byte pointerMaxState() {
    println("menu state is" + state);
    switch(state) {
    case 1:
      println("PAUSE");
      return(byte(3));

    default:
      println("default");
      return(byte(10));
    }
  }


  public void setState(byte s) {
    state = byte(s);
  }


  public void useItem() {
    if ((pointer.getState() - 1) + ((page - 1) * 10) < player.getInventory().getItems().size()) {
      Item item = player.getInventory().getItems().get(((pointer.getState() - 1) + ((page - 1) * 10)));

      switch(item.getCategory()) {
      case "HEAL":
        player.changeHP(item.getHP());

        if (item.getAmount() > 1) {
          item.changeAmount(-1) ;
        } else {
          player.getInventory().getItems().remove((pointer.getState() - 1) + ((page - 1) * 10));
        }

        break;

      default:


        break;
      }
    }
  }
  
  
  
}



public class Pointer extends Player {
  byte state = 1;



  public Pointer(int x, int y) {
    super(x, y, byte(0), byte(0));
  }


  public void drawPlayer() {

    stroke(0);
    strokeWeight(1);
    strokeJoin(MITER);

    if ((frameCount % 40 <= 30)) { //this condition makes the pointer blink, the logic is left number is the interval of frames
      fill(0);                    //and the right number is the number of frames it will be drawn for in that interval
      triangle((posX + 5) + 25, (posY + 2), (posX + 5) - 25, (posY + 2) + 25, (posX + 5) - 25, (posY + 2) - 25);
      fill(255);
      triangle((posX) + 25, (posY), (posX) - 25, (posY) + 25, (posX) - 25, (posY) - 25);
    }
  }


  public void changeState(int c) {
    int leftOver;

    if (gameState == PLAYERMENU) { //POINTER IS IN INVENTORY MODE
      if ((state + c) < 1) {
        state = byte(pause.pointerMaxState());
      } else if ((state + c) > pause.pointerMaxState()) {
        state = byte(1);
        println("gamestate 2 change");
      } else {
        state += byte(c);
      }
    } else if (gameState == BATTLE) { //POINTER IS IN BATTLE MENU MODE
      if ((state + c) < 1) {
        leftOver = -(c + state);
        println("leftOver is"  + leftOver);
        state = byte(battle.pointerMaxState());
        state -= leftOver ;
        
      } else if ((state + c) > battle.pointerMaxState()) {
        leftOver = ((c + state) - battle.pointerMaxState()) ;
        println("leftOver is"  + leftOver);
        state = byte(1);
        state += leftOver - 1;
      } else {
        println("state is" + state);
        state += byte(c);
        println("battle menu state is " + state);
        ;
      }
    }
  }



  public byte getState() {
    return(state);
  }

  public void setState(int s) {
    state = byte(s);
  }
  
  
  
}






public void game2() {



  pressed = keyPressed;
  keyPressed();
  //println(key);

  if (pressed) {
    input();
  }

  pause.drawMenu();
  //pointer.drawPlayer();



  key = '0';
  //println(key);

  if (keyPressed) {
    stillPressed = true;
  } else {
    stillPressed = false;
  }
}
/***************************************************
 **********************GAME STATE 3****************************************************************
 ****************************************************/
 
 
 
public class BattleMenu {
    final byte BASE = 0;
    final byte ATTACK = 1;
    final byte DEFEND = 2;
    final byte MAGIC = 3;
    final byte ITEMS = 4;
    final byte SHOUT = 5;
    final byte RUN = 6;
    final byte DIALOGUE = 7;
  
    boolean textBox = false;
    byte state = 0;
    byte turnActions = 1;
    String text = "";
    
    Encounter encounter;
    ArrayList<Enemy> enemies;
   
 
  
    public BattleMenu() {
      
    }
    
    
    public void battle(){
      
    }  
  
  
    public void dialogue(String s) { //text box saying what is happening in the battle
      strokeWeight(20);
      strokeJoin(ROUND);
      fill(0, 0, 255);
      rect(10, 620, 980, 370);
  
      textSize(60);
      textAlign(LEFT, TOP);
  
      text(s, 300, 600, 400, 400);
      
      pointer.drawPlayer();
    }
    
    
    public void drawEnemy(){
      
      
      for(int i = 0; i < enemies.size(); i++){
        image(enemies.get(i).getTexture(), 200 * i, 200 * i);      
        
        
      }  
       
      
    }  
  
  
    public void drawMenu() {
      background(0);
      switch(state) {
      case BASE:
        stroke(157, 162, 171);
        strokeWeight(20);
        strokeJoin(ROUND);
        fill(0, 0, 255);
        rect(10, 620, 980, 370);
  
        textSize(60);
        textAlign(CENTER);
  
        fill(0);
  
        text("HP: " + player.getHP() + "/" + player.getMaxHP(), 305, 697);
        text("MP: " + player.getMP() + "/" + player.getMaxMP(), 685, 697);
  
  
        text("Attack", 205, 767);
        text("Defend", 205, 917);
  
        text("Magic", 505, 767);
        text("Items", 505, 917);
  
        text("Shout", 805, 767);
        text("Run", 805, 917);
  
        fill(255);
  
        text("HP: " + player.getHP() + "/" + player.getMaxHP(), 300, 695);
        text("MP: " + player.getMP() + "/" + player.getMaxMP(), 680, 695);
  
        text("Attack", 200, 765);
        text("Defend", 200, 915);
  
        text("Magic", 500, 765);
        text("Items", 500, 915);
  
        text("Shout", 800, 765);
        text("Run", 800, 915);
  
        switch(pointer.getState()) {
        case ATTACK:
          pointer.teleportPlayer(60, 740, byte(0), byte(0));
          break;
  
        case DEFEND:
          pointer.teleportPlayer(60, 890, byte(0), byte(0));
          break;
  
        case MAGIC:
          pointer.teleportPlayer(380, 740, byte(0), byte(0));
          break;
  
        case ITEMS:
          pointer.teleportPlayer(380, 890, byte(0), byte(0));
          break;
  
        case SHOUT:
          println("pointer state is " + pointer.getState());
          pointer.teleportPlayer(680, 740, byte(0), byte(0));
          break;
  
        case RUN:
          pointer.teleportPlayer(680, 890, byte(0), byte(0));
          break;
        }
        
        pointer.drawPlayer();
        
        break;
  
      default:
        stroke(157, 162, 171);
        strokeWeight(20);
        strokeJoin(ROUND);
        fill(0, 0, 255);
        rect(10, 620, 980, 370);
  
        textSize(50);
        textAlign(LEFT, TOP);
        fill(0);
  
        text(text, 55, 642, 900, 770);
  
        fill(255);
  
        text(text, 50, 640, 900, 770);
        
        pointer.drawPlayer();
  
        pointer.teleportPlayer(920, 920, byte(0), byte(0));
  
        break;
      }
    }
    
    
    public void generateEncounter(){
      encounter = new Encounter();
      enemies = encounter.getEnemies();
      
    }  
    
    
    public void interact() {
      switch(state) {
          case BASE: //BASE BATTLE SCREEN
      
            switch(pointer.getState()) {
                case ATTACK:
                  state = ATTACK;
                  break;
          
                case DEFEND:
                  state = DEFEND;
                  break;
          
                case MAGIC:
                  state = MAGIC;
                  break;
          
                case ITEMS:
                  state = ITEMS;
                  break;
          
                case SHOUT:
                  text = "You shouted like a maniac";
                  state = SHOUT;
                  textBox = true;
                  pointer.setState(1);
          
                  break;
          
                case RUN:
                  text = "You ran like a coward";
                  state = RUN;
                  textBox = true;
                  pointer.setState(1);
          
                  break;
            }
      
            break;
      
          case ATTACK:
            if (textBox) {
              textBox = false;
              state = BASE;
      
            }
      
            break;
      
          case DEFEND:
            if (textBox) {
              textBox = false;
              state = BASE;
      
            }
      
            break;
      
          case MAGIC:
            if (textBox) {
              textBox = false;
              state = BASE;
      
            }
      
      
            break;
      
          case ITEMS:
            if (textBox) {
              textBox = false;
              state = BASE;
      
            }
      
      
            break;
      
          case SHOUT:
            if (textBox) {
              textBox = false;
              state = BASE;
      
            }
      
            break;
      
          case RUN:
            if (textBox) {
              textBox = false;
              state = BASE;
              gameState = OVERWORLD;
            }
      
      
            break;
          }
    }
  
    public byte pointerMaxState() {
      println("menu state is" + state);
      switch(state) {
      case 0:
        println("MAIN BATTLE MENU");
        return(byte(6));
  
      default:
        println("default");
        return(byte(1));
      }
    }
}



public class Encounter{
    ArrayList<Enemy> enemies = new ArrayList<Enemy>();  
    ArrayList<EnemyType> types = allEnemies.getArray();
    Boolean over = false;
    
    public Encounter(){
      int n = int(random(1,6));
      
      for(int i = 0; i < n; i++){
        Enemy temp = new Enemy(types.get(int((random(0, types.size())))).getName());
        temp.changeStats(int(random(0, player.getStatLevel() + 2)), int(random(0, player.getStatLevel() + 2)), int(random(0, player.getStatLevel() + 5)), 
        int(random(0, player.getStatLevel() + 5)), int(random(0, player.getStatLevel() + 5)));
        enemies.add(temp);  
        
      }  
      
      
    }
    
    public void checkHP(){
      if(enemies.size() != 0){
        for(int i = 0; i < enemies.size(); i++){
          if(enemies.get(i).getHP() < 0){
            enemies.remove(i);  
            
          }  
          
        } 
        
      } else {
        over = true;  
      
      }  
      
    }  
    
    public ArrayList<Enemy> getEnemies(){
      return(enemies); 
      
    }
        
    public int getEnemyAmount(){
      return(enemies.size());
      
    }  
    
    public boolean isOver(){
      return(over);  
      
    }  
    
  
}



public class EnemyType {
    int atk;
    int def;
    int exp;
    int gold;
    int hp;
    PImage texture;
    String name;
    
    public EnemyType(String n, PImage t, int a, int d, int h, int e, int g){
      name = n;
      texture = t;
      atk = a;
      def = d;
      hp = h;
      exp = e;
      gold = g;
      
    }
    
    public int getAtk(){
      return(atk);     
      
    }
    
    public int getDef(){
      return(def);     
      
    }
    
    public int getExp(){
      return(exp);     
      
    }
    
    public int getGold(){
      return(gold);     
      
    }
    public int getHP(){
      return(hp);     
      
    }
      
    public String getName(){
      return(name);     
      
    }
    
    public PImage getTexture(){
      return(texture);
      
    }
    
    
  
}



public class Enemy extends EnemyType {
    String text;
    
    public Enemy(String n){
      super(allEnemies.getEnemyType(n).getName(), allEnemies.getEnemyType(n).getTexture(), allEnemies.getEnemyType(n).getAtk(), allEnemies.getEnemyType(n).getDef(), 
      allEnemies.getEnemyType(n).getHP(), allEnemies.getEnemyType(n).getExp(), allEnemies.getEnemyType(n).getGold());
      
    }
    
    
    
    public void changeStats(int a, int d, int h, int e, int g){
      atk += a;
      def += d;
      hp += h;
      exp += e;
      gold += g;
      
    }
    
    public int damage(){
      return(-(int(random(atk - 3,atk))));  
      
    }
      
    public String getText(){
      return(text);  
      
    }  
    
    public void hurt(int a){
      hp -= (a - def);   
      
    }  
    
    public void turnAction(){
      float dice = random(1, 100); 
      
      if(dice < 33){
        int d = damage();
        player.changeHP(d);  
        text = (name + " hit player for " + player.hurt(damage()) + "damage");
        
      } else {
        text = (name + " picked their nose");  
        
      }  
      
      
    }  
  
}

public class EnemySet {
    ArrayList<EnemyType> enemies = new ArrayList<EnemyType>();     
  
    public EnemySet(){//Enemy constructor expects name, texture, atk, def, hp, exp, and gold
    
      enemies.add(new EnemyType("Goblin", loadImage("goblin.png"), 3, 1, 10, 3, 2));
      enemies.add(new EnemyType("Red Goblin", loadImage("redgoblin.png"), 6, 3, 20, 6, 4));
     
    }
    
     
  
    public EnemyType getEnemyType(String n) {
     for (int i = 0; i < enemies.size(); i++) {
       //println(n + "comparing to" + items.get(i).getName());
       if (n.equals(enemies.get(i).getName())) {
         return(enemies.get(i));
       }
     }
  
     return(enemies.get(0));
   }
   
   public ArrayList<EnemyType> getArray(){
     return(enemies);
     
   }  
  
}



public void game3() {



  pressed = keyPressed;
  keyPressed();
  //println(key);




  battle.drawMenu();
  if (pressed) {
    input();
  }




  key = '0';
  //println(key);

  if (keyPressed) {
    stillPressed = true;
  } else {
    stillPressed = false;
  }
}




/*********************************************************
************************************DRAW******************************************
********************************************************/
void draw() {
  //println(pressed);
  if (pauseTimer == 0) {
    //println=("Game State:" + gameState);
    switch(gameState) {
    case OVERWORLD:
      game();
      break;

    case PLAYERMENU:
      game2();
      break;

    case BATTLE:
      game3();
      break;

    default:
      text("YOU SHOULDN'T BE HERE", 300, 500);

      break;
    }
  } else {
    pauseTimer -= 1;
  }
}

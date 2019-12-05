import java.util.ArrayList;

import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.BufferedWriter;

Milkstock milkstock;
Maker maker;
Supermarket supermarket;
Superstock superstock;
Supershelf supershelf;
Track track;
MakerTrack makertrack;
SuperTrack supertrack;
Customer customer;


int day = 1;
int span = 365;
int T = 3; //倉庫から商品棚への品出し期間の総数
int E = 14; //賞味期限の最大日数

int sales_deadline = 5; //計算で出す
int delivery_deadline = 10; //計算で出す
int shelf_capacity = 50;//在庫容量
int stock_capacity = 100;
int maker_capacity = 300;

double freshness;
double price;

int order = 0;

int timemaker = 1;
int timesuper = 1;
int timetotal = 1;

ArrayList<Milkstock> buy = new ArrayList<Milkstock>();
ArrayList<ArrayList<Integer>> maker_list = new ArrayList<ArrayList<Integer>>();
ArrayList<ArrayList<Integer>> super_list = new ArrayList<ArrayList<Integer>>();
ArrayList<ArrayList<Integer>> stock_list = new ArrayList<ArrayList<Integer>>();
ArrayList<ArrayList<Integer>> shelf_list = new ArrayList<ArrayList<Integer>>();
ArrayList<ArrayList<Integer>> customer_list = new ArrayList<ArrayList<Integer>>();

ArrayList<Integer> maker_waste;
ArrayList<Integer> super_waste;
ArrayList<Integer> total_waste;
ArrayList<ArrayList<Integer>> maker_wastes = new ArrayList<ArrayList<Integer>>();
ArrayList<ArrayList<Integer>> super_wastes = new ArrayList<ArrayList<Integer>>();
ArrayList<ArrayList<Integer>> total_wastes = new ArrayList<ArrayList<Integer>>();



void setup() {
  milkstock = new Milkstock();
  maker = new Maker();
  supermarket = new Supermarket();
  superstock = new Superstock();
  supershelf = new Supershelf();
  track = new Track();
  makertrack = new MakerTrack();
  supertrack = new SuperTrack();
  customer = new Customer();
}

void draw() {
  int ms = millis();

  customer.fresh_price();//正規化するための賞味期限と価格のリストの作成

  //シミュレーション回数
  for (int time=1; time<=50; time++) {
    maker_wastes.clear();
    super_wastes.clear();
    total_wastes.clear();


    //効用freshness
    for (int f=0; f<= 100; f+=10) {
      freshness = f;

      maker_waste = new ArrayList<Integer>();
      super_waste = new ArrayList<Integer>();   
      total_waste = new ArrayList<Integer>();

      //効用money
      for (int p=0; p<=100; p+=10) {
        price = p;

        reset();
        main_scm();

        maker_waste.add(maker.maker_totalwaste);
        super_waste.add(superstock.stock_totalwaste + supershelf.shelf_totalwaste);
        total_waste.add(maker.maker_totalwaste + superstock.stock_totalwaste + supershelf.shelf_totalwaste);
      }
      maker_wastes.add(maker_waste);
      super_wastes.add(super_waste);
      total_wastes.add(total_waste);
    }


    makerwaste_file();
    superwaste_file();
    totalwaste_file();
  }

  println((millis()-ms) + "ms");

  exit();
}


void main_scm() {
  while (day <= span) {
    if (day == 1) {
      maker.maker_first();
      supermarket.super_first();
      customer.customer_first();//位置
    }

    for (int t=1; t<=T; t++) {
      if (t==1) {
        maker.shipment(makertrack, this.order);//メーカから出荷
        //makertrack.addfile();

        superstock.delivery(makertrack); //スーパー倉庫に納品
      }
      superstock.loading(supertrack, supershelf.restock()); //倉庫の牛乳をトラックに積む
      supershelf.unloading(supertrack); //トラックに入れた牛乳を商品棚に卸す（品出し）

      customer.buy(supershelf); //販売

      if (t==T) {
        maker.newstock(); //生産
        maker.maker_appdate(); //需要予測して明日の生産量決定

        int inv = supermarket.inventory(superstock, supershelf); 
        order = supermarket.super_appdate(inv, supershelf); //需要予測して発注量決定

        maker.waste(); //maker廃棄
        superstock.waste(); //super廃棄
        supershelf.waste(); //super廃棄
      }
    }

    //リストの追加
    maker.maker_list(); 
    supermarket.super_list(); 
    superstock.stock_list(); 
    supershelf.shelf_list(customer); 
    customer.customer_list(supershelf); 

    //日付の更新
    maker.m_daychange(); 
    superstock.stock_daychange(); 
    supershelf.shelf_daychange(); 
    customer.c_daychange(); 

    superstock.discount3((int)(150*0.7)); //150円の3割引き
    supershelf.discount3((int)(150*0.7)); //150円の3割引き

    day++;
  }

  maker.addfile(); 
  supermarket.addfile(); 
  customer.addfile(); 

  //makertrack.maker_addfile();
  //supertrack.super_addfile();
}

void reset() {
  day = 1; 

  maker.maker_totalwaste = 0; 
  supershelf.shelf_totalwaste = 0; 
  superstock.stock_totalwaste = 0; 

  buy.clear(); 
  maker_list.clear(); 
  super_list.clear(); 
  customer_list.clear(); 

  milkstock.clear(); 
  track.clear(); 
  maker.clear(); 
  superstock.clear(); 
  supershelf.clear(); 
  makertrack.clear(); 
  supertrack.clear();
}

void makerwaste_file() {
  try {

    //PrintWriter file = new PrintWriter(new FileWriter(new File("/Users/inouemiyu/Desktop/milk_scm/scm_" + month() + "_" + day() +"/waste/maker_waste.csv"), true));
    PrintWriter file = new PrintWriter(new FileWriter(new File("C:\\Users\\miumi\\iCloudDrive\\Desktop\\milk_scm\\scm_"+ month() + "_" + day() +"\\waste\\maker_waste.csv"), true)); 

    file.print(timemaker); 
    file.print(","); 

    for (int i=0; i<maker_wastes.size(); i++) {
      for (int j=0; j<maker_wastes.get(i).size(); j++) {
        file.print(maker_wastes.get(i).get(j)); 
        file.print(",");
      }
      file.print(",");
    }

    timemaker++; 


    file.println(""); 

    file.close();
  }
  catch (IOException e) {
    println(e); 
    e.printStackTrace();
  }
}

void superwaste_file() {
  try {
    //PrintWriter file = new PrintWriter(new FileWriter(new File("//Users/inouemiyu/Desktop/milk_scm/scm_" + month() + "_" + day() +"/waste/super_waste.csv"), true));
    PrintWriter file = new PrintWriter(new FileWriter(new File("C:\\Users\\miumi\\iCloudDrive\\Desktop\\milk_scm\\scm_"+ month() + "_" + day() +"\\waste\\super_waste.csv"), true)); 

    file.print(timesuper); 
    file.print(","); 

    for (int i=0; i<super_wastes.size(); i++) {
      for (int j=0; j<super_wastes.get(i).size(); j++) {
        file.print(super_wastes.get(i).get(j)); 
        file.print(",");
      }
      file.print(",");
    }

    timesuper++; 

    file.println(""); 

    file.close();
  }
  catch (IOException e) {
    println(e); 
    e.printStackTrace();
  }
}

void totalwaste_file() {
  try {
    PrintWriter file = new PrintWriter(new FileWriter(new File("C:\\Users\\miumi\\iCloudDrive\\Desktop\\milk_scm\\scm_"+ month() + "_" + day() +"\\waste\\total_waste.csv"), true)); 
    //PrintWriter file = new PrintWriter(new FileWriter(new File("/Users/inouemiyu/Desktop/milk_scm/scm_" + month() + "_" + day() +"/waste/total_waste.csv"), true));

    file.print(timetotal); 
    file.print(","); 

    for (int i=0; i<total_wastes.size(); i++) {
      for (int j=0; j<total_wastes.get(i).size(); j++) {
        file.print(total_wastes.get(i).get(j)); 
        file.print(",");
      }
      file.print(",");
    }

    timetotal++; 


    file.println(""); 

    file.close();
  }
  catch (IOException e) {
    println(e); 
    e.printStackTrace();
  }
}

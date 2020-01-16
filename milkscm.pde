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

int kakaku = 214;
//float waribiki = 0.7;

int sales_deadline = 5; //！！！
int delivery_deadline = 10; //！！！
int shelf_capacity = 100;//在庫容量
int stock_capacity = 100;
int maker_capacity = 300;

double freshness;
double price;
int beta_f;
int beta_p;
IntList fresh_list = new IntList();//正規化したもののリスト
IntList money_list = new IntList();
int fresh_max;
int fresh_min;
int money_max;
int money_min;
float fmax = 11.214;
float fmin = 6.133966;
float mmax = 14.8;
float mmin = 11.23599;

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

ArrayList<ArrayList<Float>> maker_wastes = new ArrayList<ArrayList<Float>>();
ArrayList<ArrayList<Float>> super_wastes = new ArrayList<ArrayList<Float>>();
ArrayList<ArrayList<Float>> total_wastes = new ArrayList<ArrayList<Float>>();

ArrayList<ArrayList<Float>> maker_wastesloss = new ArrayList<ArrayList<Float>>();
ArrayList<ArrayList<Float>> super_wastesloss = new ArrayList<ArrayList<Float>>();



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


  for (int a=0; a<4; a++) {
    switch(a) {
    case 0://3分の1
      sales_deadline = 5;
      delivery_deadline = 10;
      break;
    case 1://2分の1
      sales_deadline = 1;
      delivery_deadline = 7;
      break;
    case 2://3分の2
      sales_deadline = 1;
      delivery_deadline = 5;
      break;
    case 3://4分の3
      sales_deadline = 1;
      delivery_deadline = 4;
      break;
    }


    //効用freshness
    for (int i=0; i<= 100; i+=10) {
      beta_f = i;
      freshness = customer.satisfaction(beta_f, fmax, fmin);

      ArrayList<Float> maker_waste = new ArrayList<Float>();
      ArrayList<Float> super_waste = new ArrayList<Float>();
      ArrayList<Float> total_waste = new ArrayList<Float>();

      ArrayList<Float> maker_wasteloss = new ArrayList<Float>();
      ArrayList<Float> super_wasteloss = new ArrayList<Float>();

      //効用money
      for (int j=0; j<=100; j+=10) {
        beta_p = j;
        price = customer.satisfaction(beta_p, mmax, mmin);

        maker.newfile();
        supermarket.newfile();
        customer.newfile();

        int[] maker_average = new int[5];
        int[] super_average = new int[5];
        int[] total_average = new int[5];
        //int[] maker_average = new int[10];
        //int[] super_average = new int[10];
        //int[] total_average = new int[10];

        float[] maker_lossaverage = new float[5];
        float[] super_lossaverage = new float[5];
        //float[] total_lossaverage = new float[1];

        for (int time=0; time<5; time++) {
          reset();
          main_scm();

          maker_average[time] = maker.maker_totalwaste;
          super_average[time] = superstock.stock_totalwaste + supershelf.shelf_totalwaste;
          total_average[time] = maker.maker_totalwaste + superstock.stock_totalwaste + supershelf.shelf_totalwaste;

          maker_lossaverage[time] = maker.loss_ritsu();
          super_lossaverage[time] = supermarket.loss_ritsu(superstock.stock_totalwaste, supershelf.shelf_totalwaste);
          //total_average[time] = maker.maker_totalwaste + superstock.stock_totalwaste + supershelf.shelf_totalwaste;
        }

        maker_waste.add(average(maker_average));
        super_waste.add(average(super_average));
        total_waste.add(average(total_average));

        maker_wasteloss.add(lossaverage(maker_lossaverage));
        super_wasteloss.add(lossaverage(super_lossaverage));
        //total_waste.add(average(total_average));
      }

      maker_wastes.add(maker_waste);
      super_wastes.add(super_waste);
      total_wastes.add(total_waste);

      maker_wastesloss.add(maker_wasteloss);
      super_wastesloss.add(super_wasteloss);
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
        maker.newstock(); //生産
        maker.shipment(makertrack, this.order);//メーカから出荷
        //makertrack.addfile();

        superstock.delivery(makertrack); //スーパー倉庫に納品
      }
      superstock.loading(supertrack, supershelf.restock()); //倉庫の牛乳をトラックに積む
      supershelf.unloading(supertrack); //トラックに入れた牛乳を商品棚に卸す（品出し）

      customer.buy(supershelf); //販売

      if (t==T) {
        maker.maker_appdate(); //需要予測して明日の生産量決定

        int inv = supermarket.inventory(superstock, supershelf);
        //order = supermarket.super_appdate(inv, supershelf, customer); //需要予測して発注量決定
        order = supermarket.super_appdate(inv, supershelf.sales_num); //需要予測して発注量決定

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

    //superstock.discount2((int)(kakaku*waribiki)); //180円の2割引き
    //supershelf.discount2((int)(kakaku*waribiki)); //180円の2割引き

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
  maker.reset();
  supermarket.reset();
  supershelf.reset();
  superstock.reset();

  buy.clear();
  maker_list.clear();
  super_list.clear();
  stock_list.clear();
  shelf_list.clear();
  customer_list.clear();

  milkstock.clear();
  track.clear();
  maker.clear();
  superstock.clear();
  supershelf.clear();
  makertrack.clear();
  supertrack.clear();

  //maker_waste.clear();
  //super_waste.clear();
  //total_waste.clear();
}


float average(int[] waste) {
  float ave = 0.0;
  for (int i=0; i<waste.length; i++) {
    ave += waste[i];
  }

  return ave / waste.length;
}

float lossaverage(float[] loss) {
  float ave = 0.0;
  for (int i=0; i<loss.length; i++) {
    ave += loss[i];
  }

  return ave / loss.length;
}

void makerwaste_file() {
  try {

    //PrintWriter file = new PrintWriter(new FileWriter(new File("/Users/inouemiyu/Desktop/milk_scm/scm_" + month() + "_" + day() +"/"+sales_deadline+"_"+delivery_deadline+"/waste/maker_waste.csv"), true));
    PrintWriter file = new PrintWriter(new FileWriter(new File("C:\\Users\\miumi\\iCloudDrive\\Desktop\\卒研\\milk_scm\\scm_"+ month() + "_" + day() +"\\"+sales_deadline+"_"+delivery_deadline+"\\waste\\maker_waste.csv"), true));//！！！

    file.print("メーカ廃棄量");
    file.println(",");

    for (int i=0; i<maker_wastes.size(); i++) {
      for (int j=0; j<maker_wastes.get(i).size(); j++) {
        file.print(maker_wastes.get(i).get(j));
        file.print(",");
      }
      file.println(",");
    }

    file.print("メーカロス率");
    file.println(",");

    for (int i=0; i<maker_wastesloss.size(); i++) {
      for (int j=0; j<maker_wastesloss.get(i).size(); j++) {
        file.print(maker_wastesloss.get(i).get(j));
        file.print(",");
      }
      file.println(",");
    }

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
    //PrintWriter file = new PrintWriter(new FileWriter(new File("//Users/inouemiyu/Desktop/milk_scm/scm_" + month() + "_" + day() +"/"+sales_deadline+"_"+delivery_deadline+"/waste/super_waste.csv"), true));
    PrintWriter file = new PrintWriter(new FileWriter(new File("C:\\Users\\miumi\\iCloudDrive\\Desktop\\卒研\\milk_scm\\scm_"+ month() + "_" + day() +"\\"+sales_deadline+"_"+delivery_deadline+"waste\\super_waste.csv"), true));//！！！

    file.print("スーパー廃棄量");
    file.println(",");
    for (int i=0; i<super_wastes.size(); i++) {
      for (int j=0; j<super_wastes.get(i).size(); j++) {
        file.print(super_wastes.get(i).get(j));
        file.print(",");
      }
      file.println(",");
    }

    file.print("スーパーロス率");
    file.println(",");
    for (int i=0; i<super_wastesloss.size(); i++) {
      for (int j=0; j<super_wastesloss.get(i).size(); j++) {
        file.print(super_wastesloss.get(i).get(j));
        file.print(",");
      }
      file.println(",");
    }
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
    PrintWriter file = new PrintWriter(new FileWriter(new File("C:\\Users\\miumi\\iCloudDrive\\Desktop\\卒研\\milk_scm\\scm_"+ month() + "_" + day() +"\\"+sales_deadline+"_"+delivery_deadline+"\\waste\\total_waste.csv"), true));//！！！
    //PrintWriter file = new PrintWriter(new FileWriter(new File("/Users/inouemiyu/Desktop/milk_scm/scm_" + month() + "_" + day() +"/"+sales_deadline+"_"+delivery_deadline+"/waste/total_waste.csv"), true));

    for (int i=0; i<total_wastes.size(); i++) {
      for (int j=0; j<total_wastes.get(i).size(); j++) {
        file.print(total_wastes.get(i).get(j));
        file.print(",");
      }
      file.println(",");
    }

    file.println("");

    file.close();
  }
  catch (IOException e) {
    println(e);
    e.printStackTrace();
  }
}

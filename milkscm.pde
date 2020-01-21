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
int span = 425;
int T = 3; //倉庫から商品棚への品出し期間の総数
int E = 14; //賞味期限の最大日数

int kakaku = 216;
//float waribiki = 0.7;

int sales_deadline; //！！！
int delivery_deadline; //！！！
int shelf_capacity = 200;//在庫容量
int stock_capacity = 400;
int maker_capacity = 400;

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

int kawanai = 8;

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

ArrayList<ArrayList<Float>> maker_deliveris = new ArrayList<ArrayList<Float>>();
ArrayList<ArrayList<Float>> super_deliveris = new ArrayList<ArrayList<Float>>();
ArrayList<ArrayList<Float>> total_deliveris = new ArrayList<ArrayList<Float>>();

ArrayList<ArrayList<Float>> maker_probs = new ArrayList<ArrayList<Float>>();
ArrayList<ArrayList<Float>> super_probs = new ArrayList<ArrayList<Float>>();
ArrayList<ArrayList<Float>> total_probs = new ArrayList<ArrayList<Float>>();

//ArrayList<ArrayList<Float>> maker_wastesloss = new ArrayList<ArrayList<Float>>();
//ArrayList<ArrayList<Float>> super_wastesloss = new ArrayList<ArrayList<Float>>();



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

  beta_p = 0;
  price = customer.satisfaction(beta_p, mmax, mmin);


  for (int a=0; a<1; a++) {
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

      ArrayList<Float> maker_delivery = new ArrayList<Float>();
      ArrayList<Float> super_delivery = new ArrayList<Float>();
      ArrayList<Float> total_delivery = new ArrayList<Float>();

      ArrayList<Float> maker_prob = new ArrayList<Float>();
      ArrayList<Float> super_prob = new ArrayList<Float>();
      ArrayList<Float> total_prob = new ArrayList<Float>();

      //ArrayList<Float> maker_wasteloss = new ArrayList<Float>();
      //ArrayList<Float> super_wasteloss = new ArrayList<Float>();

      //効用money
      for (int j=0; j<=100; j+=10) {
        beta_p = j;
        price = customer.satisfaction(beta_p, mmax, mmin);

        //買わないの基準
        //for (int j=0; j<=E; j++) {
        //  //println(i);
        //  kawanai = j;

        maker.newfile();
        supermarket.newfile();
        customer.newfile();

        int[] maker_waste_ave = new int[50];
        int[] super_waste_ave = new int[50];
        int[] total_waste_ave = new int[50];

        int[] maker_delivery_ave = new int[50];
        int[] super_delivery_ave = new int[50];
        int[] total_delivery_ave = new int[50];

        //float[] maker_lossaverage = new float[5];
        //float[] super_lossaverage = new float[5];
        //float[] total_lossaverage = new float[1];

        for (int time=0; time<50; time++) {
          reset();
          main_scm();

          maker_waste_ave[time] = maker.maker_totalwaste;
          super_waste_ave[time] = superstock.stock_totalwaste + supershelf.shelf_totalwaste;
          total_waste_ave[time] = maker.maker_totalwaste + superstock.stock_totalwaste + supershelf.shelf_totalwaste;

          maker_delivery_ave[time] = maker.total_production_volume;
          super_delivery_ave[time] = superstock.total_delivery;
          total_delivery_ave[time] = maker.total_production_volume + superstock.total_delivery;

          //maker_lossaverage[time] = maker.loss_ritsu();
          //super_lossaverage[time] = supermarket.loss_ritsu(superstock.stock_totalwaste, supershelf.shelf_totalwaste);
          //total_waste_ave[time] = maker.maker_totalwaste + superstock.stock_totalwaste + supershelf.shelf_totalwaste;
        }

        float mwaste = average(maker_waste_ave);
        float swaste = average(super_waste_ave);
        float twaste = average(total_waste_ave);

        float mdelivery = average(maker_delivery_ave);
        float sdelivery = average(super_delivery_ave);
        float tdelivery = average(total_delivery_ave);

        maker_waste.add(mwaste);
        super_waste.add(swaste);
        total_waste.add(twaste);

        maker_delivery.add(mdelivery);
        super_delivery.add(sdelivery);
        total_delivery.add(tdelivery);

        maker_prob.add((mwaste / mdelivery) *100);
        super_prob.add((swaste / sdelivery) *100);
        total_prob.add((twaste / tdelivery) *100);
      }

      maker_wastes.add(maker_waste);
      super_wastes.add(super_waste);
      total_wastes.add(total_waste);

      maker_deliveris.add(maker_delivery);
      super_deliveris.add(super_delivery);
      total_deliveris.add(total_delivery);

      maker_probs.add(maker_prob);
      super_probs.add(super_prob);
      total_probs.add(total_prob);
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

    if (1 <= day && day <= 60) {
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

      //日付の更新
      maker.m_daychange();
      superstock.stock_daychange();
      supershelf.shelf_daychange();
      customer.c_daychange();

      maker.reset();
      supermarket.reset();
      supershelf.reset();
      superstock.reset();
      buy.clear();

      day++;
      continue;
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
    file.println(",");

    file.print("メーカ納品量");
    file.println(",");

    for (int i=0; i<maker_deliveris.size(); i++) {
      for (int j=0; j<maker_deliveris.get(i).size(); j++) {
        file.print(maker_deliveris.get(i).get(j));
        file.print(",");
      }
      file.println(",");
    }
    file.println(",");

    file.print("メーカ廃棄率");
    file.println(",");

    for (int i=0; i<maker_probs.size(); i++) {
      for (int j=0; j<maker_probs.get(i).size(); j++) {
        file.print(maker_probs.get(i).get(j));
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
    PrintWriter file = new PrintWriter(new FileWriter(new File("C:\\Users\\miumi\\iCloudDrive\\Desktop\\卒研\\milk_scm\\scm_"+ month() + "_" + day() +"\\"+sales_deadline+"_"+delivery_deadline+"\\waste\\super_waste.csv"), true));//！！！

    file.print("スーパー廃棄量");
    file.println(",");
    for (int i=0; i<super_wastes.size(); i++) {
      for (int j=0; j<super_wastes.get(i).size(); j++) {
        file.print(super_wastes.get(i).get(j));
        file.print(",");
      }
      file.println(",");
    }
    file.println(",");

    file.print("スーパー納品量");
    file.println(",");

    for (int i=0; i<super_deliveris.size(); i++) {
      for (int j=0; j<super_deliveris.get(i).size(); j++) {
        file.print(super_deliveris.get(i).get(j));
        file.print(",");
      }
      file.println(",");
    }
    file.println(",");

    file.print("スーパー廃棄率");
    file.println(",");

    for (int i=0; i<super_probs.size(); i++) {
      for (int j=0; j<super_probs.get(i).size(); j++) {
        file.print(super_probs.get(i).get(j));
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

    file.print("総廃棄量");
    file.println(",");

    for (int i=0; i<total_wastes.size(); i++) {
      for (int j=0; j<total_wastes.get(i).size(); j++) {
        file.print(total_wastes.get(i).get(j));
        file.print(",");
      }
      file.println(",");
    }
    file.println(",");

    file.print("総納品量");
    file.println(",");

    for (int i=0; i<total_deliveris.size(); i++) {
      for (int j=0; j<total_deliveris.get(i).size(); j++) {
        file.print(total_deliveris.get(i).get(j));
        file.print(",");
      }
      file.println(",");
    }
    file.println(",");

    file.print("総廃棄率");
    file.println(",");

    for (int i=0; i<total_probs.size(); i++) {
      for (int j=0; j<total_probs.get(i).size(); j++) {
        file.print(total_probs.get(i).get(j));
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

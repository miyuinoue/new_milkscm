class Customer {
  IntList customernum = new IntList(); 
  IntList fresh_list = new IntList();//正規化したもののリスト
  IntList money_list = new IntList();

  float A = 30;  //振幅
  float w = 12;  //角周波数（周期）
  int customertotal;
  int fresh_max;
  int fresh_min;
  int money_max;
  int money_min;
  int notbuy;

  ArrayList<Double> prob = new ArrayList<Double>();
  ArrayList<Double> utility = new ArrayList<Double>();
  ArrayList<Double> freshNorm = new ArrayList<Double>();//fresh
  ArrayList<Double> priceNorm = new ArrayList<Double>();//price 
  ArrayList<Integer> select_fre = new ArrayList<Integer>();//何回選択したか
  ArrayList<Integer> select_pri = new ArrayList<Integer>();


  Customer() {
  }

  void customer_first() {
    for (int i=0; i<14; i++) {
      select_fre.add(0);
      select_pri.add(0);
    }
  }

  void c_daychange() {
    buy.add(new Milkstock());
    customernum.clear();     
    customertotal = 0;

    for (int i=0; i<14; i++) {
      select_fre.set(i, 0);
      select_pri.set(i, 0);
    }
    this.notbuy = 0;
  }

  void fresh_price() {
    //4～14日の賞味期限を正規化するためにfresh_listに格納
    for (int i=E; i>=(sales_deadline-1); i--) {
      fresh_list.append(i);
    }

    //100円から200円までの価格を正規化するためにmoney_listに格納
    for (int i=100; i<=200; i++) {
      money_list.append(i);
    }

    fresh_max = fresh_list.max();
    fresh_min = fresh_list.min();
    money_max = money_list.max();
    money_min = money_list.min();
  }

  //来客数
  int random_customer(int d) {
    float ave = 25 + A * sin(w * radians(d));
    float random = ave + randomGaussian() * 10;//平均が循環変動ave・分散10の正規乱数

    if (random >= 0)this.customernum.append((int)random);
    else this.customernum.append(0);
    customertotal += this.customernum.get(this.customernum.size()-1);//一日の総来客数

    return this.customernum.get(this.customernum.size()-1);
  }

  //客の選択確率を計算し，購入
  void buy(Supershelf supershelf) {
    int num = random_customer(day);

    for (int i=0; i<num; i++) {
      normalization(supershelf);//賞味期限と価格を正規化
      probability();
      supershelf.sales(select());
    }
  }

  //count番目の牛乳を購入する
  int select() {     
    double random_num = sum() * Math.random();
    double prob_sum = 0;
    int count = 0 ;

    //count番目の牛乳を購入する 
    for (int i=0; i<prob.size(); i++) {
      prob_sum += prob.get(i);
      if (prob_sum >= random_num) {
        count = i;
        break;
      }
    }
    return count;
  }

  //選択確率P
  void probability() {
    prob.clear();
    utility.clear();

    for (int i=0; i<freshNorm.size(); i++) {
      double num = Math.exp(utility(freshNorm.get(i), priceNorm.get(i)));  

      prob.add(num);
      utility.add(utility(freshNorm.get(i), priceNorm.get(i)));
    }    

    prob.add(Math.exp(not_buy()));//買わない効用を付け足す
  }

  //選択確率sum
  double sum() {
    double vsum = 0;

    for (int i=0; i<freshNorm.size(); i++) {
      vsum += Math.exp(utility(freshNorm.get(i), priceNorm.get(i)));
    }
    vsum += Math.exp(not_buy());//買わない効用を付け足す

    return vsum;
  }


  //効用U
  double utility(double f, double p) {
    return (freshness * f + price * p);
  }

  //買わない選択肢のVの割合
  float not_buy() {
    return 30 + 30;//この時，効用が合計で100くらいで買わないが考慮されなくなる
  }

  //freshとmoneyの正規化
  void normalization(Supershelf supershelf) { 
    freshNorm.clear();
    priceNorm.clear();

    if (supershelf.size() == 0)return;

    int getnum = supershelf.stock();

    for (int i=getnum; i<supershelf.size(); i++) {
      for (int j=0; j<supershelf.get(i).size(); j++) {
        double x = (supershelf.get(i).get(j).expiration - fresh_min)/(double)(fresh_max - fresh_min);  
        double y = 1.0 - (supershelf.get(i).get(j).price - money_min)/(double)(money_max - money_min);

        freshNorm.add(x);
        priceNorm.add(y);
      }
    }
  }

  //なにを何回選んだか
  void select_milk() {
    if (buy.size() == 0)return;

    for (int i=0; i<buy.get(buy.size()-1).size(); i++) { 
      if (1 <= buy.get(buy.size()-1).get(i).expiration && buy.get(buy.size()-1).get(i).expiration <=14) {
        int num = 14 - buy.get(buy.size()-1).get(i).expiration;
        select_fre.set(num, select_fre.get(num)+1);
      } else if (buy.get(buy.size()-1).get(i).expiration == 100) {
        this.notbuy++;
      }
    }

    for (int i=0; i<buy.get(buy.size()-1).size(); i++) {
      if (buy.get(buy.size()-1).get(i).price == -1)continue;
      int num = (150 - buy.get(buy.size()-1).get(i).price)/5;
      select_pri.set(num, select_pri.get(num)+1);
    }
  }


  //選択回数のリスト
  void customer_list() {
    ArrayList<Integer> list = new ArrayList<Integer>();

    list.add(day);//日にち
    list.add(this.customertotal);//来店数
    //選択回数
    list.add(this.notbuy);//買わない
    for (int i=0; i<(14-sales_deadline+1); i++) {
      list.add(this.select_fre.get(i));
    }

    for (int i=0; i<(14-sales_deadline+1); i++) {
      list.add(this.select_pri.get(i));
    }

    customer_list.add(list);
  }

  void addfile() {
    try {
      //PrintWriter file = new PrintWriter(new FileWriter(new File("/Users/miyuinoue/Desktop/milk_scm/scm_" + month() + "_" + day() +"/customer/customer_"+freshness+"_"+money+".csv"), true));
      PrintWriter file = new PrintWriter(new FileWriter(new File("C:\\Users\\miumi\\iCloudDrive\\Desktop\\milk_scm\\scm_"+ month() + "_" + day() +"\\customer\\customer_"+freshness+"_"+price+".csv"), true));

      file.println("");

      file.print("day");

      file.print(",");
      file.print("raikyaku-suu");

      file.print(",");
      file.print("senntaku-kaisuu");
      file.print(",");
      file.println("");

      int kakaku = 150;
      file.print(",");
      file.print(",");

      file.print("kawanai");

      for (int i=14; i>=sales_deadline; i--) {
        file.print(",");
        file.print(i + "niti");
      }

      for (int i=14; i>=sales_deadline; i--) {
        file.print(",");
        file.print(kakaku + "enn");
        kakaku -= 5;
      }
      file.print(",");

      file.println("");

      for (int i=0; i<customer_list.size(); i++) {
        for (int j=0; j<customer_list.get(i).size(); j++) {
          file.print(customer_list.get(i).get(j));
          file.print(",");
        }
        file.println("");
      }

      file.println("");

      file.close();
    }
    catch (IOException e) {
      println(e);
      e.printStackTrace();
    }
  }
}

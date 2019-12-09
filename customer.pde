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
  double sum;


  ArrayList<Double> probnum = new ArrayList<Double>();
  ArrayList<Double> utilitynum = new ArrayList<Double>();
  int[] select_fresh = new int[14-sales_deadline+1];//何回選択したか
  int[] select_price = new int[14-sales_deadline+1];

  Customer() {
  }

  void customer_first() {
    for (int i=0; i<select_fresh.length; i++) {
      select_fresh[i] = 0;
    }
    for (int i=0; i<select_price.length; i++) {
      select_price[i] = 0;
    }
  }

  void c_daychange() {
    buy.add(new Milkstock());
    customernum.clear();     
    customertotal = 0;

    for (int i=0; i<select_fresh.length; i++) {
      select_fresh[i] = 0;
    }
    for (int i=0; i<select_price.length; i++) {
      select_price[i] = 0;
    }
    //this.notbuy = 0;
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
    int[] milkselect = new int[2];

    for (int i=0; i<num; i++) {
      probability(supershelf);
      milkselect = supershelf.sales(this.sum, this.probnum);//効用の合計値・選択確率の配列
      select_milk(milkselect);
    }
  }

  //牛乳の賞味期限と価格を正規化・選択確率と選択確率の合計値を計算
  void probability(Supershelf supershelf) {

    if (supershelf.size() == 0)return;

    this.sum = 0;
    probnum.clear();
    utilitynum.clear();

    //for (int i=supershelf.stock(); i<supershelf.size(); i++) {
    for (int i=0; i<supershelf.size(); i++) {
      if (supershelf.get(i).expiration < sales_deadline)continue;

      for (int j=0; j<supershelf.get(i).size(); j++) {
        double x = (supershelf.get(i).get(j).expiration - fresh_min)/(double)(fresh_max - fresh_min);  //fresh正規化
        double y = 1.0 - (supershelf.get(i).get(j).price - money_min)/(double)(money_max - money_min);//price正規化

        double num = Math.exp(utility(x, y));  //牛乳一つに対する効用の計算
        probnum.add(num);
        utilitynum.add(utility(x, y));

        this.sum += num;//効用の合計値
      }
    }
    probnum.add(Math.exp(not_buy()));//買わない効用を付け足す
    this.sum += Math.exp(not_buy());//買わない効用を付け足す
  }

  //効用U
  double utility(double f, double p) {
    return (freshness * f + price * p);
  }

  //買わない選択肢のVの割合
  float not_buy() {
    return 30 + 30;//この時，効用が合計で100くらいで買わないが考慮されなくなる
  }


  //なにを何回選んだか
  void select_milk(int[] selectmilk) {
    if (selectmilk[0] == -1)return;

    if (1 <= selectmilk[0] && selectmilk[0] <=14) {
      int freshnum = 14 - selectmilk[0];
      select_fresh[freshnum]++;
    }

    int pricenum = (150 - selectmilk[1])/5;
    if (selectmilk[1] != 150 && selectmilk[1] != 105)println(selectmilk[1]);
    select_price[pricenum]++;
  }



  //選択回数のリスト
  void customer_list(Supershelf supershelf) {
    ArrayList<Integer> list = new ArrayList<Integer>();

    list.add(day);//日にち
    list.add(this.customertotal);//来店数
    //選択回数
    list.add(supershelf.notbuy);//買わない
    for (int i=0; i<select_fresh.length; i++) {
      list.add(select_fresh[i]);
    }

    for (int i=0; i<select_price.length; i++) {
      list.add(select_price[i]);
    }

    customer_list.add(list);
  }

  void newfile() {
    try {
      PrintWriter file = new PrintWriter(new FileWriter(new File("C:\\Users\\miumi\\iCloudDrive\\Desktop\\milk_scm\\scm_"+ month() + "_" + day() +"\\customer\\customer_"+freshness+"_"+price+".csv"))); 
      //PrintWriter file = new PrintWriter(new FileWriter(new File("/Users/inouemiyu/Desktop/milk_scm/scm_" + month() + "_" + day() +"/customer/customer_"+freshness+"_"+price+".csv")));

      file.print("day");

      file.print(",");
      file.print("raikyakusuu");
      file.print(",");
      int kakaku = 150;
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
      file.close();
    }
    catch (IOException e) {
      println(e);
      e.printStackTrace();
    }
  }

  void addfile() {
    try {
      PrintWriter file = new PrintWriter(new FileWriter(new File("C:\\Users\\miumi\\iCloudDrive\\Desktop\\milk_scm\\scm_"+ month() + "_" + day() +"\\customer\\customer_"+freshness+"_"+price+".csv"), true)); 
      //PrintWriter file = new PrintWriter(new FileWriter(new File("/Users/inouemiyu/Desktop/milk_scm/scm_" + month() + "_" + day() +"/customer/customer_"+freshness+"_"+price+".csv"), true));

      for (int i=0; i<customer_list.size(); i++) {
        for (int j=0; j<customer_list.get(i).size(); j++) {
          file.print(customer_list.get(i).get(j));
          file.print(",");
        }
        file.println("");
      }

      file.close();
    }
    catch (IOException e) {
      println(e);
      e.printStackTrace();
    }
  }
}

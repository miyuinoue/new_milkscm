class Customer {
  IntList customernum = new IntList();
  int customerave = 30;
  float[] circulation = {1.11, 0.96, 0.96, 0.96, 0.96, 0.96, 1.11};
  float[] season = {1.00, 0.97, 0.93, 0.96, 0.96, 1.05, 1.04, 1.02, 0.97, 1.06, 1.08, 1.00, 0.96};
  float sigma = 0.1;

  // float Ac = 0.58;
  // float kc = 2*PI/7;
  // float As = 0.53;
  // float ks = 4*PI/365;
  // float sigma = 0.1;

  //float A = 30;  //振幅
  //float w = 12;  //角周波数（周期）
  int customertotal;
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

  float satisfaction(int n, float max, float min) {
    float s = (n*(max-min)/100)+min;
    return s;  //正規化
  }

  void fresh_price() {
    //1～14日の賞味期限を正規化するためにfresh_listに格納
    for (int i=E; i>=0; i--) {//！！！
      fresh_list.append(i);
    }

    //150円から250円までの価格を正規化するためにmoney_listに格納
    for (int i=150; i<=250; i++) {
      money_list.append(i);
    }

    fresh_max = fresh_list.max();
    fresh_min = fresh_list.min();
    money_max = money_list.max();
    money_min = money_list.min();
  }

  //来客数
  int customer_num(int d) {
    float c = circulation[(int)d%7];//循環変動
    float s;//季節変動
    if ((int)day/30 == 13)s = season[12];
    else s = season[(int)day/30];   
    float irregular = 0 + randomGaussian() * customerave * sigma;//不規則変動

    int num = (int)(customerave * c * s + irregular);

    if (num >= 0)this.customernum.append(num);
    else this.customernum.append(0);
    customertotal += this.customernum.get(this.customernum.size()-1);//一日の総来客数

    return this.customernum.get(this.customernum.size()-1);
  }


  // //来客数
  // int customer_num(int d) {
  //   float circulation = Ac * cos(kc * radians(d));//循環変動
  //   float season = As * sin(ks * radians(d));//季節変動
  //   float irregular = 0 + randomGaussian() * sqrt(sigma);//不規則変動
  //
  //   int num = (int)(circulation + season + irregular);
  //
  //   println(num);
  //
  //   if (num >= 0)this.customernum.append(num);
  //   else this.customernum.append(0);
  //   customertotal += this.customernum.get(this.customernum.size()-1);//一日の総来客数
  //
  //   return this.customernum.get(this.customernum.size()-1);
  // }


  ////来客数
  //int random_customer(int d) {
  //  float ave = 25 + A * sin(w * radians(d));
  //  float random = ave + randomGaussian() * 10;//平均が循環変動ave・分散10の正規乱数

  //  if (random >= 0)this.customernum.append((int)random);
  //  else this.customernum.append(0);
  //  customertotal += this.customernum.get(this.customernum.size()-1);//一日の総来客数

  //  return this.customernum.get(this.customernum.size()-1);
  //}

  //客の選択確率を計算し，購入
  void buy(Supershelf supershelf) {
    int num = customer_num(day);
    int[] milkselect = new int[2];

    for (int i=0; i<num; i++) {
      probability(supershelf);
      milkselect = supershelf.sales(this.sum, this.probnum);//sales(効用の合計値, 選択確率の配列)に対して選ばれた賞味期限・価格を返す
      //buyJudge(milkselect);
      select_milk(milkselect);
    }
  }

  //牛乳の賞味期限と価格を正規化・選択確率と選択確率の合計値を計算
  void probability(Supershelf supershelf) {

    if (supershelf.size() == 0)return;

    this.sum = 0;
    probnum.clear();
    utilitynum.clear();

    for (int i=0; i<supershelf.size(); i++) {
      if (supershelf.get(i).expiration < sales_deadline)continue;

      for (int j=0; j<supershelf.get(i).size(); j++) {
        double num = normalization(supershelf.get(i).get(j).expiration, supershelf.get(i).get(j).price);

        probnum.add(Math.exp(num));
        utilitynum.add(num);

        this.sum += num;//効用の合計値
      }
    }
    //probnum.add(Math.exp(not_buy()));//買わない効用を付け足す
    //this.sum += Math.exp(not_buy());//買わない効用を付け足す
  }

  double normalization(int f, float p) {
    double x = (f - fresh_min)/(double)(fresh_max - fresh_min);  //fresh正規化
    double y = 1.0 - (p - money_min)/(double)(money_max - money_min);//price正規化

    return utility(x, y);  //牛乳一つに対する効用の計算
  }

  //効用U
  double utility(double f, double p) {
    return (freshness * f + price * p);
  }



  ////買わない選択肢のVの割合
  //float not_buy() {
  //  return 30 + 30;//この時，効用が合計で100くらいで買わないが考慮されなくなる
  //}


  //なにを何回選んだか
  void select_milk(int[] selectmilk) {
    if (selectmilk[0] == -1)return;

    if (1 <= selectmilk[0] && selectmilk[0] <=14) {
      int num = 14 - selectmilk[0];
      select_fresh[num]++;
      select_price[num]++;

      //if (0 <= num && num <= 6) {
      //  if (selectmilk[1] != kakaku)println("error180円: " + selectmilk[1] + "円");
      //} else {
      //  int enn = (int)(kakaku * waribiki);
      //  if (selectmilk[1] != enn)println("error144円: " + selectmilk[1] + "円");
      //}
    }
  }



  //選択回数のリスト
  void customer_list(Supershelf supershelf) {
    ArrayList<Integer> list = new ArrayList<Integer>();

    list.add(day-30);//日にち
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
      PrintWriter file = new PrintWriter(new FileWriter(new File("C:\\Users\\miumi\\iCloudDrive\\Desktop\\卒研\\milk_scm\\scm_"+ month() + "_" + day() +"\\"+sales_deadline+"_"+delivery_deadline+"\\customer\\customer"+beta_f+"_"+beta_p+".csv")));//！！！
      //PrintWriter file = new PrintWriter(new FileWriter(new File("/Users/inouemiyu/Desktop/milk_scm/scm_" + month() + "_" + day() +"/"+sales_deadline+"_"+delivery_deadline+"/customer/customer"+beta_f+"_"+beta_p+".csv")));

      file.println("");
      file.print("freshness");      
      file.print(",");
      file.print(freshness);
      file.println("");
      file.print("price");      
      file.print(",");
      file.print(price);
      file.println("");
      file.println("");

      file.print("day");

      file.print(",");
      file.print("raikyakusuu");
      file.print(",");
      //int kakaku = 180;
      file.print("kawanai");

      for (int i=14; i>=sales_deadline; i--) {
        file.print(",");
        file.print(i + "niti");
      }

      for (int i=14; i>=sales_deadline; i--) {
        file.print(",");
        file.print(kakaku + "enn");
        //kakaku -= 5;
      }
      //for (int i=14; i>=8; i--) {
      //  file.print(",");
      //  file.print(kakaku + "enn");
      //  //kakaku -= 5;
      //}
      //for (int i=7; i>=5; i--) {
      //  file.print(",");
      //  file.print((int)(kakaku*waribiki) + "enn");
      //  //kakaku -= 5;
      //}
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
      PrintWriter file = new PrintWriter(new FileWriter(new File("C:\\Users\\miumi\\iCloudDrive\\Desktop\\卒研\\milk_scm\\scm_"+ month() + "_" + day() +"\\"+sales_deadline+"_"+delivery_deadline+"\\customer\\customer"+beta_f+"_"+beta_p+".csv"), true));//！！！
      //PrintWriter file = new PrintWriter(new FileWriter(new File("/Users/inouemiyu/Desktop/milk_scm/scm_" + month() + "_" + day() +"/"+sales_deadline+"_"+delivery_deadline+"/customer/customer"+beta_f+"_"+beta_p+".csv"), true));

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

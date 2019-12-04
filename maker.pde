class Maker extends ArrayList <Milkstock> {
  IntList demand = new IntList();

  int ordernum;
  int shipment;
  int production_volume = 0;
  int maker_loss;
  float standard_deviation = 0;
  float demand_forecast = 0;
  float safety_factor = 1.65;
  int saftystock_maker = 0;
  int leadtime = 1;
  int ordercycle = 1;
  int maker_waste;
  int maker_totalwaste = 0;


  Maker() {
  }


  void maker_first() {
    this.demand.clear();
    for (int i=0; i<7; i++) {
      this.demand.append(100);
    }
  }

  //日付が変わると賞味期限が-1日される
  void m_daychange() {
    for (int i=0; i < this.size(); i++) {
      this.get(i).daychange();
    }
  }

  //需要予測して生産量決定
  void maker_appdate() {
    this.demand.remove(0);
    this.demand.append(ordernum);

    this.demand_forecast();
    this.standard_deviation();
    this.safty_stock();
    produce();
  }

  void demand_forecast() {
    float sum = 0;
    for (int i=0; i<7; i++) {
      sum += this.demand.get(i);
    }
    this.demand_forecast = sum/7;
  }

  void standard_deviation() {
    float var = 0;
    for (int i=0; i<7; i++) {
      var += (this.demand.get(i) - this.demand_forecast)*(this.demand.get(i) - this.demand_forecast);
    }
    this.standard_deviation = (float)Math.sqrt(var/(7-1));
  }

  void safty_stock() {
    saftystock_maker = (int)Math.ceil(this.safety_factor * this.standard_deviation * Math.sqrt(this.leadtime + this.ordercycle));
  }

  //日付の更新
  void daychange() {
    for (int i=0; i < this.size(); i++) {
      this.get(i).daychange();
    }
  }

  //在庫量（10日の在庫は一日の最後に廃棄になるのでカウントしない）
  int inventory() {
    int inv = 0;
    for (int i=stock(); i<this.size(); i++) {
      if (this.get(i).expiration == delivery_deadline)continue;
      inv += this.get(i).size();
    }

    return inv;
  }

  //前日に生産した牛乳が倉庫に入る
  void newstock() {
    this.add(new Milkstock());
    this.get(this.size()-1).makemilk(production_volume);
  }

  //生産量q
  void produce() {
    int inventory = inventory();
    production_volume = (int)Math.ceil((this.leadtime + this.ordercycle)*this.demand_forecast - inventory + saftystock_maker);

    if (production_volume < 0)production_volume = 0;

    production_volume += maker_loss;//機会損失分も追加で生産する
  }

  //賞味期限が古い商品から順に出荷shipmentする
  void shipment(MakerTrack makertrack, int num) {   
    this.ordernum = num;
    shipment = 0;
    maker_loss = 0;

    int m = 14-delivery_deadline+1;
    makertrack.add(new Track(m));//Track(5)

    int carry;
    for (int i=this.stock(); i<this.size(); i++) {
      carry= min(num, this.get(i).size());

      num -= carry;

      for (int j=0; j<carry; j++) {
        makertrack.addtrack(this.get(i).remove(0));
        this.shipment++;
      }
      if (num<=0) break;
    }

    maker_loss = num;
  }

  //在庫の牛乳が何番目からか
  int stock() {
    int exp = this.size();

    for (int i=0; i<this.size(); i++) {
      if (this.get(i).size() == 0)continue;

      if (this.get(i).expiration >= delivery_deadline) {
        exp = i;
        break;
      }
    }
    return exp;
  }

  //納品期限を過ぎた牛乳を廃棄する
  void waste() {
    maker_waste = 0;
    for (int i=this.stock(); i<this.size(); i++) {
      maker_waste += this.get(i).waste(delivery_deadline);
    }

    maker_totalwaste += maker_waste;
  }

  void maker_list() {
    ArrayList<Integer> list = new ArrayList<Integer>();

    list.add(day);//日にち
    //賞味期限14日～10日ごとの在庫量
    for (int i=14; i>=delivery_deadline; i--) {
      boolean m = false;
      for (int j=0; j<this.size(); j++) {

        if (this.get(j).expiration == i) {
          list.add(this.get(j).size());
          m = true;
        }
      }
      if (m == false) {
        list.add(0);
      }
    }
    list.add(this.ordernum);//受注数量
    list.add((int)this.demand_forecast);//需要予測
    list.add((int)this.standard_deviation);//標準偏差
    list.add(this.saftystock_maker);//安全在庫
    list.add(this.production_volume);//生産量
    list.add(this.shipment);//出荷量
    list.add(this.maker_loss);//機会損失
    list.add(this.maker_waste);//廃棄量
    list.add(this.maker_totalwaste);//総廃棄量

    maker_list.add(list);
  }

  void addfile() {
    try {
      //PrintWriter file = new PrintWriter(new FileWriter(new File("/Users/inouemiyu/Desktop/milk_scm/scm_" + month() + "_" + day() +"/maker/maker_"+freshness+"_"+price+".csv"),true));
      PrintWriter file = new PrintWriter(new FileWriter(new File("C:\\Users\\miumi\\iCloudDrive\\Desktop\\milk_scm\\scm_"+ month() + "_" + day() +"\\maker\\maker_"+freshness+"_"+price+".csv"), true));

      file.println("");

      file.print("day");
      file.print(",");

      //maker
      file.print("syoumikigenn");//14～10日//期末在庫なので次の日に処理が行われる
      for (int i=14; i>(delivery_deadline-1); i--) {
        file.print(",");
      }
      file.print("zyutyuu");
      file.print(",");
      file.print("zyuyouyosoku");
      file.print(",");
      file.print("hyouzyunnhennsa");
      file.print(",");
      file.print("annzennzaiko");
      file.print(",");
      file.print("seisann-ryo");
      file.print(",");
      file.print("syuxtuka-ryo");
      file.print(",");
      file.print("kikaisonnsitsu");
      file.print(",");
      file.print("haiki-ryo");
      file.print(",");
      file.print("total-haiki-ryo");
      file.print(",");
      file.println("");

      for (int i=14; i>(delivery_deadline-1); i--) {
        file.print(",");
        file.print(i + "niti");
      }
      file.println("");



      for (int i=0; i<maker_list.size(); i++) {
        for (int j=0; j<maker_list.get(i).size(); j++) {
          file.print(maker_list.get(i).get(j));
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

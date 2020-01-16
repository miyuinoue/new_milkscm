class Supershelf extends ArrayList <Milkstock> {
  int restocknum;
  int notbuy;
  int sales_loss = 0;
  int total_sales_loss = 0;
  int sales_num = 0;
  int total_sales_num = 0;
  int profit = 0;
  int waribiki_profit = 0;
  int loss_kinngaku = 0;
  int visitors = 0;
  int shelf_waste;
  int shelf_totalwaste = 0;
  int[] select_milk = new int[2];

  Supershelf() {
  }

  //日付が変わると賞味期限が-1日される
  void shelf_daychange() {
    for (int i=0; i < this.size(); i++) {
      this.get(i).daychange();
    }
    visitors = 0;
    sales_num = 0;
    sales_loss = 0;
    this.notbuy = 0;
  }

  void reset() {
    total_sales_loss = 0;
    total_sales_num = 0;
    shelf_totalwaste = 0;
    profit = 0;
    waribiki_profit = 0;
  }

  //在庫量
  int inventory() {
    int inv = 0;

    for (int i=0; i<this.size(); i++) {
      if (this.get(i).expiration < sales_deadline)continue;
      inv += this.get(i).size();
    }

    return inv;
  }

  //補充数（shelfの最大在庫量 - shelfの現在の在庫量）
  int restock() {
    return shelf_capacity - this.inventory();
  }

  //前期に足らなかった牛乳を補充する
  void unloading(SuperTrack supertrack) {      
    restocknum = 0;//品出しした量

    int i = supertrack.size()-1;

    for (int j=0; j<supertrack.get(i).size(); j++) {
      if (supertrack.get(i).get(j).size() == 0)continue;

      //if (supertrack.get(i).get(j).expiration < 1)println("day:" + day + "  supertrack:" + supertrack.get(i).get(j).expiration + "日");//println

      //スーパーの倉庫が空の場合
      if (this.size() == 0) {
        this.add((Milkstock)supertrack.get(i).get(j).clone());
        restocknum += supertrack.get(i).get(j).size();
        continue;
      }

      boolean noExpiration = true;
      int e = supertrack.get(i).get(j).expiration;

      //納品された牛乳の賞味期限日数と同じ牛乳がstockにある場合
      for (int l=0; l<this.size(); l++) {
        if (this.get(l).expiration < sales_deadline)continue;

        if (e == this.get(l).expiration) {
          noExpiration = false;
          this.get(l).addAll((Milkstock)supertrack.get(i).get(j).clone());
          restocknum += supertrack.get(i).get(j).size();

          //if (this.get(l).expiration < 1)println("day:" + day + "  superunloading1:" + this.get(l).expiration + "日");//println

          continue;
        }
      }

      //納品された牛乳の賞味期限日数と同じ牛乳がstockにない場合
      if (noExpiration == true) {
        this.add((Milkstock)supertrack.get(i).get(j).clone());
        //if (this.get(this.size()-1).expiration < 1)println("day:" + day + "  superunloading2:" + this.get(this.size()-1).expiration + "日");//println

        restocknum += supertrack.get(i).get(j).size();
      }
    }
  }


  //ランダムに選択した牛乳を購入・販売する
  int[] sales(double s, ArrayList<Double> prob) {  
    //スーパー商品棚に牛乳がなかったら機会損失
    if (this.inventory() == 0) {
      sales_loss++;
      total_sales_loss++;
      select_milk[0] = -1;
      select_milk[1] = -1;
      //return select_milk;
    }
    double random_num = s * Math.random();
    double prob_sum = 0;
    int count = 0 ;

  loop: 
    for (int i=0; i<this.size(); i++) {
      if (this.get(i).expiration < sales_deadline)continue;

      for (int j=0; j<this.get(i).size(); j++) {
        prob_sum += prob.get(count);
        //if (this.get(i).expiration < 1)println("day:" + day + "  sales:" + this.get(i).expiration + "日");//println

        if (prob_sum >= random_num) {     
          buyJudge(i, j);//i行目j列目の牛乳が選ばれたので、買わない効用とルーレット選択する
          break loop;
        }
        count++;
      }
    }
    return select_milk;
  }

  void buyJudge(int i, int j) {
    //if (this.get(i).expiration < 1)println("day:" + day + "  buyJudge:" + this.get(i).expiration + "日");//println

    double sum = 0;
    double prob[] = new double[2];

    double num = customer.normalization(this.get(i).get(j).expiration, this.get(i).get(j).price);
    prob[0] = Math.exp(num);    
    sum += Math.exp(num);//効用の合計値

    num = customer.normalization(8, kakaku);//一番効用が小さい場所//！！！
    prob[1] = Math.exp(num);    
    sum += Math.exp(num);//効用の合計値


    double random_num =  sum * Math.random();
    if (prob[0] >= random_num) {  

      select_milk[0] = this.get(i).get(j).expiration;
      select_milk[1] = this.get(i).get(j).price;

      if (buy.size() == 0)buy.add(new Milkstock());

      buy.get(buy.size()-1).add(this.get(i).remove(j));
      this.sales_num++;
      this.total_sales_num++;

      this.profit += select_milk[1];//売上高
      //if (select_milk[1] == (kakaku*waribiki)) {
      //  this.waribiki_profit += kakaku*(1-waribiki);
      //}
    } else {
      select_milk[0] = -1;
      select_milk[1] = -1;
      this.notbuy++;
    }
  }


  //販売期限を過ぎた牛乳を廃棄する
  void waste() {
    shelf_waste = 0;
    for (int i=0; i<this.size(); i++) {
      if (this.get(i).expiration < sales_deadline)continue;
      shelf_waste += this.get(i).waste(sales_deadline);
    }

    shelf_totalwaste += shelf_waste;
  }

  ////賞味期限が残り3日になったら3割引きする
  //void discount2(int d) {
  //  for (int i=0; i<this.size(); i++) {
  //    if (this.get(i).expiration < sales_deadline)continue;

  //    if (5 <= this.get(i).expiration && this.get(i).expiration <= 7) {
  //      for (int j=0; j<this.get(i).size(); j++) {
  //        this.get(i).price(d);
  //      }
  //    }
  //  }
  //}

  void shelf_list(Customer customer) {
    ArrayList<Integer> list = new ArrayList<Integer>();

    //賞味期限ごとの在庫量
    for (int i=14; i>=sales_deadline; i--) {
      boolean sh = false;
      for (int j=0; j<this.size(); j++) {

        if (this.get(j).expiration == i) {
          list.add(this.get(j).size());
          sh = true;
        }
      }
      if (sh == false) {
        list.add(0);
      }
    }
    list.add(this.restocknum);//品出し納品量
    //来客数    
    for (int i=0; i<customer.customernum.size(); i++) {
      list.add(customer.customernum.get(i));
    }
    list.add(customer.customertotal);//総来客数
    list.add(this.sales_num);//販売数
    list.add(this.total_sales_num);//総販売数
    list.add(this.sales_loss);//機会損失
    list.add(this.total_sales_loss);//総機会損失
    list.add(this.notbuy);//買わない
    list.add(this.shelf_waste);//廃棄量
    list.add(this.shelf_totalwaste);//総廃棄量

    shelf_list.add(list);
  }
}

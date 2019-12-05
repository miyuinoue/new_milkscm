class Superstock extends ArrayList <Milkstock> {
  IntList restockList = new IntList();

  int delivery;
  int loadingnum;
  int stock_loss;
  int stock_waste;
  int stock_totalwaste = 0;

  Superstock() {
  }

  //日付が変わると賞味期限が-1日される
  void stock_daychange() {
    for (int i=0; i < this.size(); i++) {
      this.get(i).daychange();
    }
    restockList.clear();
  }

  void delivery(MakerTrack makertrack) {    
    delivery = 0;//納品量

    int i = makertrack.size()-1;
    for (int j=0; j<makertrack.get(i).size(); j++) {    
      if (makertrack.get(i).get(j).size() == 0)continue;

      //スーパーの倉庫が空の場合
      if (this.size() == 0 ) {
        this.add((Milkstock)makertrack.get(i).get(j).clone());
        this.get(this.size()-1).price(milk_price(this.get(this.size()-1).expiration));
        delivery += makertrack.get(i).get(j).size();
        continue;
      }

      boolean noExpiration = true;
      int e = makertrack.get(i).get(j).expiration;

      //納品された牛乳の賞味期限日数と同じ牛乳がstockにある場合
      //for (int k=this.stock(); k<this.size(); k++) {
      for (int k=0; k<this.size(); k++) {
        if (this.get(k).expiration < sales_deadline)continue;

        if (e == this.get(k).expiration) {
          noExpiration = false;
          this.get(k).addAll((Milkstock)makertrack.get(i).get(j).clone());
          this.get(k).price(milk_price(this.get(k).expiration));
          delivery += makertrack.get(i).get(j).size();
        }
      }

      //納品された牛乳の賞味期限日数と同じ牛乳がstockにない場合 or スーパーの倉庫が空の場合
      if (noExpiration == true) {
        this.add((Milkstock)makertrack.get(i).get(j).clone());
        this.get(this.size()-1).price(milk_price(this.get(this.size()-1).expiration));
        delivery += makertrack.get(i).get(j).size();
      }
    }
  }

  //賞味期限が古い商品から順に品出しrestockingする
  //古い順に、納品できるかの判定を行い、牛乳一つずつtrackのboxに入れる
  void loading(SuperTrack supertrack, int s) {
    loadingnum = 0;//トラックに積んだ量
    stock_loss = 0;

    supertrack.add(new Track(14-sales_deadline+1));

    int carry;
    //for (int i=this.stock(); i<this.size(); i++) {
    for (int i=0; i<this.size(); i++) {
      if (this.get(i).expiration < sales_deadline)continue;

      carry = min(s, this.get(i).size());
      s -= carry;

      for (int j=0; j<carry; j++) {
        supertrack.addtrack(this.get(i).remove(0));
        loadingnum++;
      }
      if (s <= 0) break;
    }


    stock_loss = s;

    restockList.append(loadingnum);//t期に何個品出ししたかのリスト
  }

  ////在庫の牛乳が何番目からか
  //int stock() {
  //  int exp = this.size();

  //  for (int i=0; i<this.size(); i++) {
  //    //if (this.get(i).size() == 0)continue;

  //    if (this.get(i).expiration >= sales_deadline) {
  //      exp = i;
  //      break;
  //    }
  //  }
  //  return exp;
  //}

  //販売期限を過ぎた牛乳を廃棄する
  void waste() {
    stock_waste = 0;
    //for (int i=this.stock(); i<this.size(); i++) {
    for (int i=0; i<this.size(); i++) {
      if (this.get(i).expiration < sales_deadline)continue;
      stock_waste += this.get(i).waste(sales_deadline);
    }

    stock_totalwaste += stock_waste;
  }

  //値段の設定（今は一律150円）
  int milk_price(int r) {
    int num = E - r;
    //return (150-5*num);
    return 150;
  }

  //賞味期限が残り3日になったら3割引きする
  void discount3(int d) {
    //for (int i=stock(); i<this.size(); i++) {
    for (int i=0; i<this.size(); i++) {
      if (this.get(i).expiration < sales_deadline)continue;

      if (5 <= this.get(i).expiration && this.get(i).expiration <= 7) {
        for (int j=0; j<this.get(i).size(); j++) {
          this.get(i).price(d);
        }
      }
    }
  }

  void stock_list() {
    ArrayList<Integer> list = new ArrayList<Integer>();

    //賞味期限ごとの在庫量
    for (int i=14; i>(sales_deadline-1); i--) {
      boolean st = false;
      for (int j=0; j<this.size(); j++) {

        if (this.get(j).expiration == i) {
          list.add(this.get(j).size());
          st = true;
        }
      }

      if (st == false) {
        list.add(0);
      }
    }
    list.add(this.delivery);//納品量
    //品出し出荷量
    if (this.restockList.size()==0) {
      for (int i=0; i<3; i++)list.add(0);
    }
    for (int i=0; i<this.restockList.size(); i++) {
      list.add(this.restockList.get(i));
    }
    list.add(this.stock_loss);//機会損失
    list.add(this.stock_waste);//廃棄量
    list.add(this.stock_totalwaste);//総廃棄量

    stock_list.add(list);
  }
}

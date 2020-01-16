class MakerTrack extends ArrayList <Track> {

  MakerTrack() {
  }

  void addtrack(Milk milk) {
    this.get(this.size()-1).maker_addtrack(milk);
  }


//  void addfile() {
//    try {
//      //PrintWriter file = new PrintWriter(new FileWriter(new File("/Users/inouemiyu/Desktop/milk_scm/scm_" + month() + "_" + day() +"/maker/maker_"+freshness+"_"+price+".csv"),true));
//      PrintWriter file = new PrintWriter(new FileWriter(new File("C:\\Users\\miumi\\iCloudDrive\\Desktop\\卒研\\milk_scm\\scm_"+ month() + "_" + day() +"\\track\\makertrack_2_3_"+beta_f+"_"+beta_p+".csv"), true));//！！！

//      file.println("");
//      file.print("freshness");      
//      file.print(",");
//      file.print(freshness);
//      file.println("");
//      file.print("price");      
//      file.print(",");
//      file.print(price);
//      file.println("");
      
//      file.println("");
//      for (int i=0; i<this.get(this.size()-1).size(); i++) {
//        file.print(this.get(this.size()-1).get(i).expiration);
//        file.print(",");
//        file.print(this.get(this.size()-1).get(i).size());
//        file.println("");
//      }

//      file.println("");

//      file.close();
//    }
//    catch (IOException e) {
//      println(e);
//      e.printStackTrace();
//    }
//  }
}

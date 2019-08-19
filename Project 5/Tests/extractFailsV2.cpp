vector<Student_info> extract_fails(vector<Student_info>&students){
  vector<Student_info> fail;
  vector<Student_info>::const_iterator iter = students.begin() ;

  while(iter != students.end()){
    if(fgrade(*iter){
      fail.push_back(*iter);
      iter = student.erase(iter);
    } else { ++iter;}
  }
  return fail;
}

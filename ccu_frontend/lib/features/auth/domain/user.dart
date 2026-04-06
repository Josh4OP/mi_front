class User{
  final String email;
  final String password;

  User({
    required this.email,
    required this.password
  });

  bool isValidEmail(){
    return email.endsWith("@utb.edu.co");
  }
  bool isValidPassword(){
    return password.length >= 8;
  }
  
}
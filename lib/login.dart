import 'package:flutter/material.dart';
import 'package:instagram/main2.dart';
import 'package:instagram/resources/auth_methods.dart';
import 'package:instagram/utils/utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _email = TextEditingController();
  TextEditingController _pass = TextEditingController();
  bool isLoading = false;

  Future<void> Login() async {
    setState(() {
      isLoading = true;
    });
    String result =
        await AuthMethods().LoginUser(email: _email.text, password: _pass.text);

    if (result == "success") {
      print("executed .................");
      setState(() {
        _email.clear();
        _pass.clear();
      });
      showSnackBar("Login Done Successfully!", context);
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=> Main2()));
    } else {
      showSnackBar("Login Failed", context);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: Container(
            padding: MediaQuery.of(context).size.width > webScreenSize
                ? EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width / 3)
                : EdgeInsets.symmetric(horizontal: 35),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // SizedBox(height: 50),
                Image.asset('assets/insta.png', color: Colors.white),
                SizedBox(height: 60),
                TextField(
                  controller: _email,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _pass,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    ),
                  ),
                ),
                SizedBox(height: 15),

                Container(
                  width: double.infinity,
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    child: Text('Forgot password?',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.lightBlue,
                        )),
                    onTap: () {},
                  ),
                ),

                SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // login code
                      Login();
                    },
                    child: isLoading
                        ? Center(
                            child:
                                CircularProgressIndicator(color: Colors.white),
                          )
                        : Text(
                            'Login',
                            style: TextStyle(fontSize: 17),
                          ),
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account? ",
                style: TextStyle(fontSize: 16),
              ),
              InkWell(
                child: Text(
                  "SignUp",
                  style: TextStyle(color: Colors.lightBlue, fontSize: 16),
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/signupScreen');
                },
              )
            ],
          ),
        ));
  }
}

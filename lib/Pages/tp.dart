import 'package:easy_upi_payment/easy_upi_payment.dart';
import 'package:flutter/material.dart';

class UPIPage extends StatelessWidget {
  const UPIPage({super.key});
  Future<void> sendMoney() async{
    final res = await EasyUpiPaymentPlatform.instance.startPayment(
      EasyUpiPaymentModel(
        payeeVpa: '7977634067',
        payeeName: 'ani',
        amount: 1,
        description: 'Testing payment',
      ),
    );
    // TODO: add your success logic here
    print(res);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
            child: InkWell(
                onTap: (){
                  sendMoney();
                },
                child: Text('Pay'))
        ),
      ),
    );
  }
}
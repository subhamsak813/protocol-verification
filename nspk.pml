#define Nonce(a) a-3
#define PublicKey(x) x-6
mtype ={NULL,Msg1,Msg2,Msg3,A,B,I,Na,Nb,Ni,PKa,PKb,PKi};
bit IniRunningAB=0;
bit IniCommitAB=0;
bit ResRunningAB=0;
bit ResCommitAB=0;
chan network =[0] of {mtype,mtype,mtype,mtype};
//#define IniRunning(a,b)
#define IniCommit(a,b)
#define ResRunning(partner,b)
#define ResCommit(partner,b)
#define Analysis(msg,data1,data2,data3)
#define CreateMessage(msg,data1,data2,data3)
#define  IsValidMessage(data1,data2,data3,data4,data5,data6)
#define IniRunning(x,y) 
    // if
   // ::(a==A&&b==B)||(a==B&&b==A)->IniRunning=1;
	  //  ::else->skip;
	//fi
//A->I:{Na,A}PKi;
//I(A)->B:{Na,A}PKb;
//B->A:{Na,Nb}PKa;
//A->I:{Nb}PKi;
//I(A)->B:{Nb}PKb;	
proctype Initiator(mtype a,b)
{ 	mtype x,y;
           IniRunning(x,y) {
	if
		::(x==A&&y==B)||(x==B&&y==A)->IniRunningAB=1;
		::else->skip;
	fi;
}
	IniRunningAB=1;
	IniCommitAB=1;
     	  mtype nb;
	atomic{
                IniRunning(a,b);
	network!Msg1,Nonce(a),a,PublicKey(b);
	}
atomic{
network?eval(Msg2),eval(Nonce(a)),nb,eval(PublicKey(a));
IniCommit(a,b);
network!Msg3,PublicKey(b),NULL;
}
28    }
proctype Responder(mtype b)
{
	ResRunningAB=1;
	ResCommitAB=1;
	mtype na,partner;
	atomic{
	network?eval(Msg1),na,partner,eval(PublicKey(b));
	ResRunning(partner,b);
	network!Msg2,na,Nonce(b),PublicKey(partner);
	ResCommit(partner,b);
	}
	network?eval(Msg3),eval(Nonce(b)),eval(PublicKey(b)),eval(NULL);

}
proctype Intruder()
{
	mtype msg,data1,data2,data3;
	mtype oldmsg,data4,data5,data6;
	mtype Knows[30];
	mtype ReverseKeys[30];
	d_step{
	Knows[A-1]=1;
	Knows[B-1]=1;
	Knows[I-1]=1;
	Knows[PKi-1]=1;
	Knows[PKa-1]=1;
	Knows[PKb-1]=1;
	ReverseKeys[PKi-1]=1;
}
	
do
::network?msg,data1,data2,data3->
atomic
{
	Analysis(msg,data1,data2,data3)
 	if
	::skip
	::oldmsg=msg;data4=data1;data5=data2;data6=data3;
	fi;

	if
	::skip;
	::network!msg,data1,data2,data3;
	fi;
}

::CreateMessage(msg,data1,data2,data3)
atomic
{
	IsValidMessage(data1,data2,data3,data4,data5,data6)
		network!msg,data1,data2,data3;
}

//::(network!oldmsg,data4,data5,data6);

od;

}
//inline Analysis(msg,data1,data2,data3)
//{
//if
//::msg==Msg1&&ReverseKeys[data3-1]->d_step{Knows[data1-1]=1;Knows[data2-1]=1;}
//::msg==Msg2&&ReverseKeys[data3-1]->d_step{Knows[data1-1]=1;Knows[data2-1]=1;}
//::msg==Msg3&&ReverseKeys[data2-1]->Knows[data1-1]=1;
//::else->skip;
//fi;
//}
inline CreateMessage(msg,data1,data2,data3)
{
	if
	::msg==Msg1->atomic{
		if
		      ::data1=Na;
		      ::data2=Nb;
	                      ::data3=Ni;
	  	fi;
		if
			::data2=A;data3=PKb;
			::data2=B;data3=PKa;
			::data2=I;data3=PKa;
			::data2=A;data3=PKb;
		fi;
	}
	::msg==Msg2->atomic{
	if
		::data1=Na;
	 	::data2=Nb;
		::data1=Ni;
	fi;
	if
		::data2=Na;
		::data2=Nb;
		::data2=Ni;
	fi;
	if
		::data3=PKa;
		::data3=Pkb;
	fi;
	}
	::msg==Msg3->atomic{
	if
		::data1=Nb;data2=PKb;
		::data1=Na;data2=PKa;
	fi;
	data3=NULL;
	}
fi;
}

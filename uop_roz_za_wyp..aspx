<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<%@ import Namespace="Soneta.Kadry" %><%@ import Namespace="Soneta.Place" %><%@ import Namespace="Soneta.Kadry" %><%@ import Namespace="Soneta.KadryPlace" %><%@ import Namespace="Soneta.Core" %><%@ import Namespace="Soneta.Tools" %><%@ import Namespace="Soneta.Types" %><%@ import Namespace="Soneta.Kalend" %><%@ import Namespace="Soneta.Business" %><%@ import Namespace="System.ComponentModel" %><%@ Register TagPrefix="ea" Namespace="Soneta.Web" Assembly="Soneta.Web" %><%@ Register TagPrefix="eb" Namespace="Soneta.Core.Web" Assembly="Soneta.Core.Web" %><%@ Page language="c#" AutoEventWireup="false" codePage="1200" %><HTML><HEAD><TITLE>UmowaParetti</TITLE>
<SCRIPT runat="server">
// <![CDATA[
	static int umowaID = 0;
	static int id;


	public class _Info : ContextBase
	{
		public _Info(Context context) : base(context)
		{
		}

		string okresWyp ="";
		[Caption("Okres wypowiedzenia")]
		[Priority(1)]
		public string OkresWyp {
			get { return okresWyp; }
			set {
				okresWyp = value;
				OnChanged(EventArgs.Empty);
			}
		}


        string dataZakWyp ="";
		[Caption("Data zakonczenia okresu")]
		[Priority(10)]
		public string DataZakWyp {
			get { return dataZakWyp; }
			set {
				dataZakWyp = value;
				OnChanged(EventArgs.Empty);
			}
		}

      

	}

	_Info info;
	[Context]
	public _Info Info {
		set { info = value; }
	}



	void dc_ContextLoad(object sender, EventArgs e) {


        okresWypID.EditValue = info.OkresWyp;
        dataKoncaID.EditValue = info.DataZakWyp;
       
		PracHistoria ph = (PracHistoria)dc[typeof(PracHistoria)];
		data.EditValue = DateTime.Now.ToString("yyyy-MM-dd");

	   
	}

	
// ]]>
</SCRIPT>

<META name=CODE_LANGUAGE content=C#>
<META name=vs_defaultClientScript content=JavaScript>
<META name=vs_targetSchema 
content=http://schemas.microsoft.com/intellisense/ie5>
<STYLE type=text/css>
        .auto-style2 {
        font-weight: normal;
    }
    .auto-style3 {
        margin-top: 21px;
    }
    .auto-style4 {
        font-family: "Times New Roman", serif;
        font-size: 14pt;
    }
    .auto-style5 {
        width: 770px;
    }
    .auto-style6 {
        margin-left: 40px;
        margin-bottom: 0.28cm;
    }
    .auto-style7 {
        width: 388px;
    }
    .auto-style8 {
        font-weight: normal;
        width: 388px;
    }
    </STYLE>
</HEAD>
<BODY>
<FORM method=post runat="server"><ea:DataContext runat="server" ID="dc" OnContextLoad="dc_ContextLoad" TypeName="Soneta.Kadry.PracHistoria,Soneta.KadryPlace" RightMargin="-2" PageSize=""></ea:DataContext>
<TABLE width="100%">
  <TBODY>
  <TR align=center>
    <TH>
      <P class=auto-style3 
      style="TEXT-ALIGN: left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
      ........................................ <BR><FONT size=3>(pieczęć 
      nagłówka pracodawcy)</FONT> </P></TH>
    <TH>
      <P class=auto-style3 style="TEXT-ALIGN: right">Opole, <ea:DataLabel runat="server" EncodeHTML="True" ID="data"> </ea:DataLabel></P></TH></TR></TBODY></TABLE>
<P>&nbsp;</P>
<P class=auto-style4 style="MARGIN-BOTTOM: 0.28cm; LINE-HEIGHT: 108%" 
align=center><STRONG>ROZWIĄZANIE UMOWY O PRACĘ ZA WYPOWIEDZENIEM</STRONG></P>
<P class=western style="MARGIN-BOTTOM: 0.28cm; LINE-HEIGHT: 108%" 
align=center><STRONG></STRONG>&nbsp;</P>
<TABLE width="100%">
  <TBODY>
  <TR>
    <TH class=auto-style5></TH>
    <TH class=auto-style2 align=left>Pan (Pani) </TH></TR>
  <TR>
    <TH class=auto-style5></TH>
    <TH align=left><ea:DataLabel runat=server DataMember="Imie" EncodeHTML="True"></ea:DataLabel>&nbsp;<ea:DataLabel runat=server DataMember="Nazwisko" EncodeHTML="True"></ea:DataLabel></TH></TR></TBODY></TABLE>
<P class=auto-style6 style="LINE-HEIGHT: 108%" align=left>Rozwiązuję z&nbsp; 
Panem (Panią) umowę o pracę&nbsp;<ea:DataLabel runat=server DataMember="Etat.TypUmowy" EncodeHTML="True"></ea:DataLabel><EM> </EM>zawartą w 
dniu&nbsp;<ea:DataLabel runat=server DataMember="Etat.Okres.From" EncodeHTML="True"></ea:DataLabel>&nbsp;z zachowaniem <ea:DataLabel runat=server  EncodeHTML="True" ID="okresWypID"></ea:DataLabel>
    okresu wypowiedzenia, który upłynie w dniu <ea:DataLabel runat=server  EncodeHTML="True" ID="dataKoncaID"></ea:DataLabel>


</P>

<P class=auto-style6 style="LINE-HEIGHT: 108%" align=left>&nbsp;</P>
<P class=auto-style6 style="LINE-HEIGHT: 108%" align=left>Jednocześnie 
informuję, iż w terminie 7 dni od dnia doręczenia niniejszego pisma przysługuje 
Panu (Pani) prawo wniesienia odwołania do Sądu Rejonowego - Sądu Pracy w 
Opolu</P>
<P class=western 
style="MARGIN-BOTTOM: 0.28cm; LINE-HEIGHT: 108%; TEXT-INDENT: 1.25cm" 
align=justify><BR></P>
<P>&nbsp;</P>
<DIV>
<TABLE>
  <TBODY>
  <TR align=center>
    <TH class=auto-style7>_______________________</TH>
    <TH>_______________________</TH></TR>
  <TR style="FONT-SIZE: 9px" align=center>
    <TH class=auto-style8>(data, podpis pracownika)</TH>
    <TH class=auto-style2>(podpis pracodawcy lub osoby reprezentującej 
      pracodawcę albo osoby<BR>&nbsp;upoważnionej do składania oświadczeń w 
      imieniu pracodawcy)</TH></TR></TBODY></TABLE></DIV></FORM>
<P>&nbsp;</P>
<P>&nbsp;</P>
<P>&nbsp;</P></BODY></HTML>

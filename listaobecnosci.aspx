<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<%@ Register TagPrefix="ea" Namespace="Soneta.Web" Assembly="Soneta.Web" %><%@ Register TagPrefix="eb" Namespace="Soneta.Core.Web" Assembly="Soneta.Core.Web" %><%@ import Namespace="Soneta.Business" %>
<%@ import Namespace="Soneta.Types" %><%@ import Namespace="Soneta.Tools" %><%@ import Namespace="Soneta.Kadry" %><%@ Import Namespace="Soneta.Core" %>
<%@ Page language="c#" AutoEventWireup="false" codePage="1200" %>

<script runat="server">

    public enum Miesiac {
        Styczeń, Luty, Marzec, Kwiecień, Maj, Czerwiec, Lipiec, Sierpień, Wrzesień, Październik, Listopad, Grudzień
    }

    public enum Dni
    {
        poniedziałek, wtorek, środa, czwartek, piątek, sobota, niedziela
    }

    public class Params : ContextBase
    {
        public Params(Context context) : base(context)
        {
        }

        Miesiac miesiac = Miesiac.Styczeń;
        [Priority(1)]
        [Caption("Wybierz miesiąc")]
        public Miesiac Miesiac
        {
            get { return miesiac; }
            set
            {
                miesiac = value;
                OnChanged(EventArgs.Empty);
            }
        }
    }
    Params pars;
    [Context]
    public Params Pars {
        get { return pars; }
        set { pars = value; }
    }



    int monthToNum(Miesiac  pars)
    {
        switch (pars.ToString())
        {
            case "Styczeń":
                return 1;

            case "Luty":
                return 2;


            case "Marzec":
                return 3;


            case "Kwiecień":
                return 4;


            case "Maj":
                return 5;


            case "Czerwiec":
                return 6;


            case "Lipiec":
                return 7;


            case "Sierpień":
                return 8;


            case "Wrzesień":
                return 9;


            case "Październik":
                return 10;


            case "Listopad":
                return 11;


            case "Grudzień":
                return 12;

            default:
                return 0;

        }
    }

    string daysToPL(string day)
    {
        switch (day.ToString())
        {
            case "Monday":
                return "Poniedziałek";

            case "Tuesday":
                return "Wtorek";


            case "Wednesday":
                return "Środa";


            case "Thursday":
                return "Czwartek";


            case "Friday":
                return "Piątek";


            case "Saturday":
                return "Sobota";


            case "Sunday":
                return "Niedziela";

            default:
                return "error not set day";

        }
    }


    void dc_ContextLoad(object sender, EventArgs e) {

        data.EditValue = pars.Miesiac+" "+DateTime.Today.Year;

        int numOfMonth = monthToNum(pars.Miesiac);
        int year = Date.Today.Year;
        int LastDay = DateTime.DaysInMonth(year, numOfMonth);

        DateTime dateStart = new DateTime(year, numOfMonth , 1);
        DateTime dateEnd = new DateTime(year,numOfMonth , LastDay);

        string tableHeader = "<table width="+addQuation("720")+" border="+addQuation("1")+"style="+addQuation("border-collapse: collapse; text-align:center; padding-right:200px;")+"><tr><td>Dzień</td><td>Dzień tygodnia</td><td>Godziny pracy</td><td>Podpis pracownika</td><td>Godziny normalne</td><td>Godziny nadliczbowe</td><td>Godziny nocne</td><td>Podpis kierownika</td></tr>                        ";

        for (int i = dateStart.Day; i <= dateEnd.Day; i++)
        {
            DateTime currentDay = new DateTime(year, numOfMonth, i);


            if(daysToPL(currentDay.DayOfWeek.ToString())=="Niedziela" || daysToPL(currentDay.DayOfWeek.ToString())=="Sobota")
            {
                 tableHeader += "<tr bgcolor="+addQuation("#e6e6e6")+"> <td>" + i + "</td> <td>" + daysToPL(currentDay.DayOfWeek.ToString())+"</td> <td></td> <td></td>  <td></td>  <td></td>  <td></td>  <td></td> </tr>";
            }
            else
            {
                tableHeader += "<tr> <td>" + i + "</td> <td>" + daysToPL(currentDay.DayOfWeek.ToString())+"</td> <td></td> <td></td>  <td></td>  <td></td>  <td></td>  <td></td> </tr>";
            }
            
        }
        tableHeader += "</table>";

        table.EditValue = tableHeader;

    }

    string addQuation(string value)
    {
        char quation = '"';
        return quation + value + quation;
    }


</script>
<HTML><HEAD><TITLE>Lista Obecności</TITLE>
<META name=CODE_LANGUAGE content=C#>
<META name=vs_defaultClientScript content=JavaScript>
<META name=vs_targetSchema 
content=http://schemas.microsoft.com/intellisense/ie5></HEAD>
<BODY>
  
<FORM method=post runat="server">

<P><ea:DataContext runat="server" ID="dc" OnContextLoad="dc_ContextLoad" TypeName="Soneta.Kadry.PracHistoria,Soneta.KadryPlace" PageSize="-1"></ea:DataContext></P>
Lista obecności  :  <ea:DataLabel runat="server" EncodeHTML="True" ID="data"></ea:DataLabel> 
  <img alt="" align="right" hspace="20" src="http://www.paretti.pl/images/logo150.png" height="80px" width="" style="text-align: right" />   
<P>Firma : <ea:DataLabel runat=server DataMember="Etat.Wydzial.Nazwa" EncodeHTML="True"></ea:DataLabel></br>
Nazwisko Imię : <ea:DataLabel runat=server DataMember="Nazwisko" EncodeHTML="True"></ea:DataLabel>&nbsp;<ea:DataLabel runat=server DataMember="Imie" EncodeHTML="True"></ea:DataLabel></br>
Stanowisko : <ea:DataLabel runat=server DataMember="Etat.Stanowisko" EncodeHTML="True"></ea:DataLabel></P>  


<ea:DataLabel runat="server" EncodeHTML="false" ID="table"></ea:DataLabel>
 






</FORM></BODY></HTML>

<%@ Register TagPrefix="ea" Namespace="Soneta.Web" Assembly="Soneta.Web" %>
<%@ Page language="c#" AutoEventWireup="false" codePage="65001" %>
<%@ import Namespace="Soneta.Deklaracje.PIT" %>
<%@ import Namespace="Soneta.Business" %>
<%@ import Namespace="Soneta.Types" %>
<%@ import Namespace="Soneta.Kadry" %>
<%@ import Namespace="Soneta.Tools" %>
<%@ import Namespace="Soneta.Core" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" >
<HTML>
	<HEAD>
		<title>NIP-7 (3)</title>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		<meta content="Microsoft Visual Studio 7.0" name="GENERATOR">
		<meta content="C#" name="CODE_LANGUAGE">
		<meta content="JavaScript" name="vs_defaultClientScript">
		<meta content="http://schemas.microsoft.com/intellisense/ie5" name="vs_targetSchema">
		<script runat="server">
		public enum _PrzeznaczenieFormularza {
            ZgłoszenieIdentyfikacyjne, ZgłoszenieAktualizacyjne
        }
        public class Params : ContextBase {
            public readonly PracHistoria historia;
            public Params(Context context)
                : base(context) {
                historia = (PracHistoria)context[typeof(PracHistoria)];
                zgłoszenie = historia.NIP == "";
                foreach (RachunekBankowyPracownika rbp in historia.Pracownik.Rachunki)
                    if (!rbp.Blokada) {
                        rachunek = rbp;
                        break;
                    }
            }
            public bool zgłoszenie;
            [Priority(10)]
            [Caption("Przeznacz.formularza")]
            public _PrzeznaczenieFormularza PrzeznaczenieFormularza {
                get { return zgłoszenie ? _PrzeznaczenieFormularza.ZgłoszenieIdentyfikacyjne : _PrzeznaczenieFormularza.ZgłoszenieAktualizacyjne; }
                set {
                    zgłoszenie = value == _PrzeznaczenieFormularza.ZgłoszenieIdentyfikacyjne;
                    OnChanged(EventArgs.Empty);
                }
            }
            RachunekBankowyPracownika rachunek;
            [Caption("Rachunek bankowy")]
            [Priority(50)]
            public RachunekBankowyPracownika Rachunek {
                get { return rachunek; }
                set {
                    rachunek = value;
                    if (rachunek != null)
                        rezygnacja = false;
                    OnChanged(EventArgs.Empty);
                }
            }
            public LookupInfo.Item GetListRachunek() {
                return Soneta.Kasa.RachBankPodmiot.RachunkiPodmiotuLookup(historia.Pracownik);
            }
            bool rezygnacja;
            [Caption("Rezygnacja z rachunku")]
            [Priority(60)]
            public bool Rezygnacja {
                get { return rezygnacja; }
                set {
                    rezygnacja = value;
                    OnChanged(EventArgs.Empty);
                }
            }
            public bool IsReadOnlyRezygnacja() {
                return rachunek != null;
            }
            bool rezygnacjaMail;
            [Caption("Rezygnacja z mail")]
            [Priority(70)]
            public bool RezygnacjaMail {
                get { return rezygnacjaMail; }
                set {
                    rezygnacjaMail = value;
                    OnChanged(EventArgs.Empty);
                }
            }
        }
		Params info;
        [Context]
        public Params Info {
            set { info = value; }
        }
        void OnContextLoad(object sender, EventArgs e) {
            if (dc.OverPrint) {
                dc.LeftMargin = 6;
                dc.TopMargin = 6;
                dc.PageZoom = "114%";
            }
            if (info.zgłoszenie)
                p5_1.EditValue = true;
            else
                p5_2.EditValue = true;
            if (!info.zgłoszenie) {
                PracHistoria prev = (PracHistoria)info.historia.Pracownik.Historia.GetPrev(info.historia);
                if (prev != null) {
                    zp10.EditValue = string.Compare(prev.Nazwisko, info.historia.Nazwisko, true) != 0;
                    zp12.EditValue = string.Compare(prev.Imie, info.historia.Imie, true) != 0;
                    zp14.EditValue = string.Compare(prev.ImieDrugie, info.historia.ImieDrugie, true) != 0;
                    zp16.EditValue = string.Compare(prev.ImieOjca, info.historia.ImieOjca, true) != 0;
                    zp18.EditValue = string.Compare(prev.ImieMatki, info.historia.ImieMatki, true) != 0;
                    zp20.EditValue = prev.Urodzony.Data!=info.historia.Urodzony.Data;
                    zp22.EditValue = string.Compare(prev.Urodzony.Miejsce, info.historia.Urodzony.Miejsce, true) != 0;
                    zp25.EditValue = string.Compare(prev.NazwiskoRodowe, info.historia.NazwiskoRodowe, true) != 0;
                    zp27.EditValue = prev.Dokument.Rodzaj != info.historia.Dokument.Rodzaj;
                    zp29.EditValue = string.Compare(prev.Dokument.SeriaNumer, info.historia.Dokument.SeriaNumer, true) != 0;
                }
            }
            if (info.Rezygnacja)
                rachunekRezygnacja.EditValue = true;
            else if (info.Rachunek != null) {
                Soneta.Kasa.RachunekBankowy rb = info.Rachunek.Rachunek;
                if (rb.Bank != null) {
                    if (rb.Bank.Adres.Kraj != "" && rb.Bank.Adres.Kraj.ToLower() != "polska")
                        rachunekKraj.EditValue = rb.Bank.Adres.Kraj;
                    rachunekNazwaBanku.EditValue = rb.Bank.Nazwa;
                }
                if (info.Rachunek.Nazwa1 != "")
                    rachunekPosiadacz.EditValue = info.Rachunek.Nazwa1 + ", " + info.Rachunek.Nazwa2;
                else
                    rachunekPosiadacz.EditValue = info.historia.Pracownik.ImięNazwisko + ", " + info.historia.Adres.Linia1 + ", " + info.historia.Adres.Linia2;
                rachunekNumer.EditValue = "Numer IBAN: " + rb.Numer + (!string.IsNullOrEmpty(rb.SWIFT) ? ", Kod SWIFT: " + rb.SWIFT : "");
            }
            Framelabel55.EditValue = Framelabel57.EditValue = Framelabel70.EditValue = "Numer IBAN:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;, Kod SWIFT:";

            if (info.historia.AdresDoKorespondencji.Ulica.Length > 0 ||
                info.historia.AdresDoKorespondencji.NrDomu.Length > 0 ||
                info.historia.AdresDoKorespondencji.NrLokalu.Length > 0 ||
                info.historia.AdresDoKorespondencji.Miejscowosc.Length > 0) {
                AdresKrajK.EditValue = info.historia.AdresDoKorespondencji.Kraj;
                AdresWojewodztwoK.EditValue = info.historia.AdresDoKorespondencji.Wojewodztwo;
                AdresPowiatK.EditValue = info.historia.AdresDoKorespondencji.Powiat;
                AdresGminaK.EditValue = info.historia.AdresDoKorespondencji.Gmina;
                AdresUlicaK.EditValue = info.historia.AdresDoKorespondencji.Ulica;
                AdresNrDomuK.EditValue = info.historia.AdresDoKorespondencji.NrDomu;
                AdresNrLokaluK.EditValue = info.historia.AdresDoKorespondencji.NrLokalu;
                AdresMiejscowoscK.EditValue = info.historia.AdresDoKorespondencji.Miejscowosc;
                AdresKodPocztowyK.EditValue = info.historia.AdresDoKorespondencji.KodPocztowy;
                AdresPocztaK.EditValue = info.historia.AdresDoKorespondencji.Poczta;
            }

            if (info.RezygnacjaMail)
                checkAdresElektronicznyRezyg.EditValue = true;
            else
                AdresElektroniczny.EditValue = info.historia.Kontakt.EMAIL;
        }
        static void Msg(object value) {
        }
		    
    </script>
	</HEAD>
	<body leftMargin="0" rightMargin="0">
		<form id="NIP_7_3" method="post" runat="server">
			<ea:deklaracjaheader id="DeklaracjaHeader1" style="Z-INDEX: 100; LEFT: 0px; POSITION: absolute; TOP: 0px"
				runat="server" Width="630px" StylNagłówka="WypałniaSkładającyCRP"></ea:deklaracjaheader>
<ea:framelabel id="FrameLabel21" style="Z-INDEX: 101; LEFT: 0px; POSITION: absolute; TOP: 21px"
				runat="server" Width="273px" ValueStyle="nip_w" DataMember="NIP" Height="28px" 
                Text="1. Identyfikator podatkowy NIP"></ea:framelabel>
<ea:framelabel id="FrameLabel22" style="Z-INDEX: 102; LEFT: 273px; POSITION: absolute; TOP: 21px"
				runat="server" Width="119px" Height="28px" Text="Nr dokumentu" FrameStyle="SmallBoldGray" Number="2"></ea:framelabel>
<ea:framelabel id="FrameLabel23" style="Z-INDEX: 103; LEFT: 392px; POSITION: absolute; TOP: 21px"
				runat="server" Width="77px" Height="30px" Text="Status" FrameStyle="SmallBoldGray" Number="3"></ea:framelabel>
<ea:framelabel id="Framelabel77" style="Z-INDEX: -2; LEFT: 0px; POSITION: absolute; TOP: 49px; height: 50px; width: 629px;"
				runat="server"></ea:frameLabel>
<ea:framelabel id="FrameLabel34" style="Z-INDEX: -1; LEFT: 85px; POSITION: absolute; TOP: 56px; height: 51px;"
				runat="server" Width="525px" 
                Text="ZGŁOSZENIE IDENTYFIKACYJNE/ZGŁOSZENIE AKTUALIZACYJNE &lt;.INDEXUP&gt;1)&lt;./&gt; OSOBY FIZYCZNEJ BĘDĄCEJ PODATNIKIEM LUB PŁATNIKIEM" 
                FrameStyle="BigBold" FrameBorderStyle="None" HorizontalAlign="Center"></ea:framelabel>
<ea:framelabel id="labelPIT" 
                style="Z-INDEX: 104; LEFT: 15px; POSITION: absolute; TOP: 62px; width: 71px; right: 821px;" 
                runat="server" Height="21px" FrameStyle="BigBold" FrameBorderStyle="None" 
                Text="NIP-7"></ea:framelabel>
<ea:framelabel id="FrameLabel24" style="Z-INDEX: 105; LEFT: 0px; POSITION: absolute; TOP: 98px; height: 133px;"
				runat="server" Width="630px" FrameStyle="SmallBoldYellow" 
                FrameBorderStyle="DoubleBottom"></ea:framelabel>
<ea:framelabel id="Framelabel18" style="Z-INDEX: -2; LEFT: 0px; POSITION: absolute; TOP: 98px; height: 80px; width: 629px;"
				runat="server"></ea:frameLabel>
<ea:framelabel id="FrameLabel28" style="Z-INDEX: 106; LEFT: 7px; POSITION: absolute; TOP: 100px; height: 10px;"
				runat="server" Width="300px" Text="Formularz przeznaczony dla osób fizycznych:"
                FrameStyle="SmallBoldYellow" FrameBorderStyle="None"></ea:framelabel>
<ea:framelabel id="FrameLabel5" style="Z-INDEX: 107; LEFT: 7px; POSITION: absolute; TOP: 109px; height: 75px;"
				runat="server" Width="590px"
                Text="a) niebędących przedsiębiorcami:&lt;br&gt;
                - prowadzących samodzielnie działalność gospodarczą lub&lt;br&gt;
                - podlegających zarejestrowaniu jako podatnicy podatku od towarów i usług lub będących zarejestrowanymi podatnikami podatku od towarów i usług, lub&lt;br&gt;
                - będących płatnikami podatków, lub&lt;br&gt;
                - będących płatnikami składek na ubezpieczenia społeczne oraz ubezpieczenia zdrowotne, lub&lt;br&gt;
                - nieobjętych rejestrem PESEL;&lt;br&gt;
                b) będących przedsiębiorcami prowadzącymi samodzielnie działalność gospodarczą w zakresie działalności, do której nie stosuje się przepisów ustawy o swobodzie działalności gospodarczej."
                FrameStyle="SmallBoldYellow" FrameBorderStyle="None"></ea:framelabel>
<ea:framelabel id="FrameLabel25" style="Z-INDEX: 109; LEFT: 7px; POSITION: absolute; TOP: 182px; right: 821px;"
				runat="server" Width="91px" Height="14px" Text="Podstawa prawna:" 
                FrameStyle="SmallYellow" FrameBorderStyle="None"></ea:framelabel>
<ea:framelabel id="FrameLabel26" style="Z-INDEX: 112; LEFT: 133px; POSITION: absolute; TOP: 182px"
				runat="server" Width="490px" Height="21px" Text='Ustawa z dnia 13 października 1995 r. o zasadach ewidencji i identyfikacji podatników i płatników (Dz. U. z 2012 r. poz. 1314 oraz<br>
z 2013 r. poz. 2 oraz z 2014 r. poz. 1161), zwana dalej „ustawą".' FrameStyle="SmallYellow"
				FrameBorderStyle="None"></ea:framelabel>
<ea:framelabel id="FrameLabel30" style="Z-INDEX: 114; LEFT: 7px; POSITION: absolute; TOP: 202px"
				runat="server" Width="91px" Height="7px" Text="Termin składania:" 
                FrameStyle="SmallYellow" FrameBorderStyle="None"></ea:framelabel>
<ea:framelabel id="FrameLabel31" style="Z-INDEX: 115; LEFT: 133px; POSITION: absolute; TOP: 202px; height: 8px;"
				runat="server" Width="490px" Text="Zgodnie z art. 6, 7 i 9 ustawy."
				FrameStyle="SmallYellow" FrameBorderStyle="None"></ea:framelabel>
<ea:framelabel id="FrameLabel32" style="Z-INDEX: 116; LEFT: 7px; POSITION: absolute; TOP: 214px"
				runat="server" Width="91px" Height="7px" Text="Miejsce składania:" 
                FrameStyle="SmallYellow" FrameBorderStyle="None"></ea:framelabel>
<ea:framelabel id="FrameLabel33" style="Z-INDEX: 117; LEFT: 133px; POSITION: absolute; TOP: 214px; height: 10px;"
				runat="server" Width="490px" Text="Zgłoszenie składa się do naczelnika urzędu skarbowego  właściwego w rozumieniu art.4 ustawy."
				FrameStyle="SmallYellow" FrameBorderStyle="None"></ea:framelabel>
<ea:framelabel id="FrameLabel17" style="Z-INDEX: 118; LEFT: 0px; POSITION: absolute; TOP: 230px; height: 238px;"
				runat="server" Width="630px" Text="A. CEL  I MIEJSCE ZŁOŻENIA ZGŁOSZENIA&lt;/font&gt;&lt;br&gt;&lt;.Footer&gt;
                Jeżeli w poz.4 nie zaznaczono kwadratu nr 1 lub 2 pominąć część C i D.2. W poz.5 zaznaczyć kwadrat nr 1: gdy formularz jest
                składany jako zgłoszenie identyfikacyjne, w celu nadania NIP albo kwadrat nr 2: gdy formularz jest składany jako zgłoszenie aktualizacyjne,
                w przypadku zmiany danych objętych zgłoszeniem, tzn. zmiany danych składającego lub zmiany naczelnika urzędu skarbowego właściwego
                w sprawach ewidencji, lub zaistnienia nowych okoliczności. W przypadku zgłoszenia aktualizacyjnego wystarczy wypełnić poz. 1 oraz części A, B.1. (poz. 8, 10, 18 i 29),
                B.3., E, F, a także inne pozycje, gdy dane się zmieniły."
                FrameStyle="BigYellowBold" FrameBorderStyle="DoubleBottom"></ea:framelabel>
<ea:framelabel id="Framelabel19" style="Z-INDEX: 120; LEFT: 28px; POSITION: absolute; TOP: 300px; width: 601px;"
				runat="server" Height="105px" 
                Text="Status ewidencyjny &lt;.Normal&gt;(zaznaczyć właściwy kwadrat lub kwadraty):&lt;./&gt;" 
                Number="4"></ea:frameLabel>
<ea:checklabel id="p4_1" style="Z-INDEX: 121; LEFT: 33px; POSITION: absolute; TOP: 310px"
				runat="server" Width="600px" DataMember="" Height="14px" Text="osoba prowadząca działalność gospodarczą," 
                Number="1" NumberAlignLeft="False"></ea:checklabel>
<ea:checklabel id="p4_2" style="Z-INDEX: 122; LEFT: 33px; POSITION: absolute; TOP: 328px"
				runat="server" Width="600px" DataMember="" Height="14px" Text="osoba podlegająca zarejestrowaniu jako podatnik podatku od towarów i usług lub będąca zarejestrowanym podatnikiem podatku od towarów i usług," 
                Number="2" NumberAlignLeft="False"></ea:checklabel>
<ea:checklabel id="p4_3" style="Z-INDEX: 123; LEFT: 33px; POSITION: absolute; TOP: 346px"
				runat="server" Width="600px" DataMember="" Height="14px" Text="płatnik podatków," 
                Number="3" NumberAlignLeft="False"></ea:checklabel>
<ea:checklabel id="p4_4" style="Z-INDEX: 124; LEFT: 33px; POSITION: absolute; TOP: 364px"
				runat="server" Width="600px" DataMember="" Height="14px" Text="płatnik składek na ubezpieczenia społeczne oraz ubezpieczenia zdrowotne," 
                Number="4" NumberAlignLeft="False"></ea:checklabel>
<ea:checklabel id="p4_5" style="Z-INDEX: 125; LEFT: 33px; POSITION: absolute; TOP: 382px"
				runat="server" Width="600px" DataMember="" Height="14px" Text="podatnik nieobjęty rejestrem PESEL." 
                Number="5" NumberAlignLeft="False"></ea:checklabel>
<ea:framelabel id="Framelabel147" style="Z-INDEX: 126; LEFT: 28px; POSITION: absolute; TOP: 405px; width: 601px;"
				runat="server" Height="28px" 
                Text="Przeznaczenie formularza &lt;.Normal&gt;(zaznaczyć właściwy kwadrat):&lt;./&gt;" 
                Number="5"></ea:frameLabel>
<ea:checklabel id="p5_1" style="Z-INDEX: 127; LEFT: 33px; POSITION: absolute; TOP: 412px; right: 751px;"
				runat="server" Width="136px" Height="14px" Text="Zgłoszenie identyfikacyjne" 
                Number="1" NumberAlignLeft="False">
            </ea:checkLabel>
<ea:checklabel id="p5_2" style="Z-INDEX: 128; LEFT: 163px; POSITION: absolute; TOP: 412px"
				runat="server" Width="136px" Height="14px" Text="Zgłoszenie aktualizacyjne" Number="2" 
                NumberAlignLeft="False">
            </ea:checkLabel>
<ea:framelabel id="p6" style="Z-INDEX: 129; LEFT: 28px; POSITION: absolute; TOP: 433px; width: 601px;"
				runat="server" Height="28px" 
                Text="Naczelnik urzędu skarbowego, do którego jest adresowane zgłoszenie" Number="6" 
                DataMember="Podatki.UrzadSkarbowy.Nazwa">
            </ea:framelabel>
<ea:framelabel id="FrameLabel1" style="Z-INDEX: 134; LEFT: 0px; POSITION: absolute; TOP: 468px"
				runat="server" Width="630px" Height="28px" Text="B. DANE SKŁADAJĄCEGO" 
                FrameStyle="BigYellowBold"></ea:framelabel>
<ea:framelabel id="FrameLabel2" style="Z-INDEX: 135; LEFT: 0px; POSITION: absolute; TOP: 496px; height: 243px;"
				runat="server" Width="630px" Text="B.1. DANE IDENTYFIKACYJNE&lt;/font&gt;&lt;.Footer&gt;
                - w przypadku osób fizycznych objętych rejestrem PESEL źródłem ich danych jest rejestr PESEL, a
                poniżej - w celu prawidłowej identyfikacji - należy wypełnić jedynie poz. 7, 8, 10. W przypadku osób nieobjętych rejestrem PESEL (w poz.4
                zaznaczony kwadrat nr 5) dla wskazania zmiany danych należy zaznaczyć odpowiedni kwadrat."
                FrameStyle="BigYellow"></ea:framelabel>
<ea:framelabel id="FrameLabel3" style="Z-INDEX: 136; LEFT: 28px; POSITION: absolute; TOP: 545px; width: 231px; right: 688px;"
				runat="server" Height="28px" Text="Numer PESEL &lt;.INDEXUP&gt;2)" Number="7" 
                DataMember="PESEL"></ea:framelabel>
<ea:framelabel id="FrameLabel4" style="Z-INDEX: 137; LEFT: 259px; POSITION: absolute; TOP: 545px; height: 28px; width: 310px;"
				runat="server" DataMember="Nazwisko" Text="Nazwisko" Number="8"></ea:framelabel>
<ea:framelabel id="FrameLabel20" style="Z-INDEX: 138; LEFT: 567px; POSITION: absolute; TOP: 545px; height: 28px; width: 60px;"
				runat="server" DataMember="" Text="Zmiana w poz.8" Number="9"></ea:framelabel>
<ea:checklabel id="zp10" style="Z-INDEX: 139; LEFT: 605px; POSITION: absolute; TOP: 552px; width: 23px;"
				runat="server" Height="14px"></ea:checklabel>
<ea:framelabel id="FrameLabel6" style="Z-INDEX: 140; LEFT: 28px; POSITION: absolute; TOP: 573px; right: 751px; width: 231px;"
				runat="server" DataMember="Imie" Height="28px" Text="Pierwsze imię" Number="10"></ea:framelabel>
<ea:framelabel id="FrameLabel27" style="Z-INDEX: 141; LEFT: 259px; POSITION: absolute; TOP: 573px; height: 28px; width: 60px;"
				runat="server" DataMember="" Text="Zmiana w poz.10" Number="11"></ea:framelabel>
<ea:checklabel id="zp12" style="Z-INDEX: 142; LEFT: 297px; POSITION: absolute; TOP: 580px; width: 23px;"
				runat="server" Height="14px"></ea:checklabel>
<ea:framelabel id="FrameLabel7" style="Z-INDEX: 142; LEFT: 322px; POSITION: absolute; TOP: 573px; width: 245px;"
				runat="server" DataMember="ImieDrugie" Height="28px" Text="Drugie imię" Number="12"></ea:framelabel>
<ea:framelabel id="FrameLabel29" style="Z-INDEX: 143; LEFT: 567px; POSITION: absolute; TOP: 573px; height: 28px; width: 60px;"
				runat="server" DataMember="" Text="Zmiana w poz.12" Number="13"></ea:framelabel>
<ea:checklabel id="zp14" style="Z-INDEX: 144; LEFT: 605px; POSITION: absolute; TOP: 580px; width: 23px;"
				runat="server" Height="14px"></ea:checklabel>
<ea:framelabel id="FrameLabel9" style="Z-INDEX: 145; LEFT: 28px; POSITION: absolute; TOP: 601px; width: 231px;"
				runat="server" DataMember="ImieOjca" Height="28px" Text="Imię ojca" Number="14"></ea:framelabel>
<ea:framelabel id="FrameLabel35" style="Z-INDEX: 146; LEFT: 259px; POSITION: absolute; TOP: 601px; height: 28px; width: 60px;"
				runat="server" DataMember="" Text="Zmiana w poz.14" Number="15"></ea:framelabel>
<ea:checklabel id="zp16" style="Z-INDEX: 147; LEFT: 297px; POSITION: absolute; TOP: 608px; width: 23px;"
				runat="server" Height="14px"></ea:checklabel>
<ea:framelabel id="FrameLabel8" style="Z-INDEX: 148; LEFT: 322px; POSITION: absolute; TOP: 601px; width: 245px; right: 289px;"
				runat="server" DataMember="ImieMatki" Height="28px" Text="Imię matki" Number="16"></ea:framelabel>
<ea:framelabel id="FrameLabel36" style="Z-INDEX: 149; LEFT: 567px; POSITION: absolute; TOP: 601px; height: 28px; width: 60px;"
				runat="server" DataMember="" Text="Zmiana w poz.16" Number="17"></ea:framelabel>
<ea:checklabel id="zp18" style="Z-INDEX: 150; LEFT: 605px; POSITION: absolute; TOP: 608px; width: 23px;"
				runat="server" Height="14px"></ea:checklabel>
<ea:framelabel id="Framelabel105" style="Z-INDEX: 151; LEFT: 28px; POSITION: absolute; TOP: 629px; width: 231px; right: 609px;"
				runat="server" ValueStyle="Date" DataMember="Urodzony.Data" Height="28px" 
                Text="Data urodzenia" Number="18"></ea:framelabel>
<ea:framelabel id="FrameLabel37" style="Z-INDEX: 152; LEFT: 259px; POSITION: absolute; TOP: 629px; height: 28px; width: 60px;"
				runat="server" DataMember="" Text="Zmiana w poz.18" Number="19"></ea:framelabel>
<ea:checklabel id="zp20" style="Z-INDEX: 153; LEFT: 297px; POSITION: absolute; TOP: 636px; width: 23px;"
				runat="server" Height="14px"></ea:checklabel>
<ea:framelabel id="Framelabel103" style="Z-INDEX: 154; LEFT: 322px; POSITION: absolute; TOP: 629px; width: 245px;"
				runat="server" DataMember="Urodzony.Miejsce" Height="28px" Number="20" 
                Text="Miejsce (miejscowość) urodzenia"></ea:framelabel>
<ea:framelabel id="FrameLabel38" style="Z-INDEX: 155; LEFT: 567px; POSITION: absolute; TOP: 629px; height: 28px; width: 60px;"
				runat="server" DataMember="" Text="Zmiana w poz.20" Number="21"></ea:framelabel>
<ea:checklabel id="zp22" style="Z-INDEX: 156; LEFT: 605px; POSITION: absolute; TOP: 636px; width: 23px;"
				runat="server" Height="14px"></ea:checklabel>
<ea:framelabel id="FrameLabel10" style="Z-INDEX: 157; LEFT: 28px; POSITION: absolute; TOP: 657px; width: 231px;"
				runat="server" Height="28px" Text="Płeć &lt;.Normal&gt;(zaznaczyć właściwy kwadrat):" 
                Number="22"></ea:framelabel>
<ea:checklabel id="p24_2" style="Z-INDEX: 158; LEFT: 141px; POSITION: absolute; TOP: 664px"
				runat="server" Width="136px" DataMember="Plec" Height="14px" Text="mężczyzna" 
                Number="2" NumberAlignLeft="False" ComparedValue="Mężczyzna"></ea:checkLabel>
<ea:checklabel id="p24_1" style="Z-INDEX: 159; LEFT: 34px; POSITION: absolute; TOP: 664px; right: 761px;"
				runat="server" Width="136px" Height="14px" Text="kobieta" Number="1" 
                NumberAlignLeft="False" ComparedValue="Kobieta" DataMember="Plec"></ea:checkLabel>
<ea:framelabel id="FrameLabel11" style="Z-INDEX: 160; LEFT: 259px; POSITION: absolute; TOP: 657px; width: 310px;"
				runat="server" DataMember="NazwiskoRodowe" Height="28px" Text="Nazwisko rodowe (według aktu urodzenia)" 
                Number="23"></ea:framelabel>
<ea:framelabel id="FrameLabel39" style="Z-INDEX: 161; LEFT: 567px; POSITION: absolute; TOP: 657px; height: 28px; width: 60px;"
				runat="server" DataMember="" Text="Zmiana w poz.23" Number="24"></ea:framelabel>
<ea:checklabel id="zp25" style="Z-INDEX: 162; LEFT: 605px; POSITION: absolute; TOP: 664px; width: 23px;"
				runat="server" Height="14px"></ea:checklabel>
<ea:framelabel id="FrameLabel13" style="Z-INDEX: 163; LEFT: 28px; POSITION: absolute; TOP: 685px; bottom: 363px;"
				runat="server" Width="231px" DataMember="Dokument.Rodzaj" Height="28px" 
                Text="Rodzaj dokumentu stwierdzającego tożsamość" Number="25">
    <ValuesMap><ea:ValuesPair Key="Niezdefiniowany" Value="" /></ValuesMap>
</ea:framelabel>
<ea:framelabel id="FrameLabel40" style="Z-INDEX: 164; LEFT: 259px; POSITION: absolute; TOP: 685px; height: 28px; width: 60px;"
				runat="server" DataMember="" Text="Zmiana w poz.25" Number="26"></ea:framelabel>
<ea:checklabel id="zp27" style="Z-INDEX: 165; LEFT: 297px; POSITION: absolute; TOP: 692px; width: 23px;"
				runat="server" Height="14px"></ea:checklabel>
<ea:framelabel id="FrameLabel12" style="Z-INDEX: 166; LEFT: 322px; POSITION: absolute; TOP: 685px; width: 245px;"
				runat="server" DataMember="Dokument.SeriaNumer" Height="28px" 
                Text="Seria i numer dokumentu stwierdzającego tożsamość" 
                Number="27"></ea:framelabel>
<ea:framelabel id="FrameLabel42" style="Z-INDEX: 167; LEFT: 567px; POSITION: absolute; TOP: 685px; height: 28px; width: 60px;"
				runat="server" DataMember="" Text="Zmiana w poz.27" Number="28"></ea:framelabel>
<ea:checklabel id="zp29" style="Z-INDEX: 168; LEFT: 605px; POSITION: absolute; TOP: 692px; width: 23px;"
				runat="server" Height="14px"></ea:checklabel>
<ea:framelabel id="FrameLabel15" style="Z-INDEX: 169; LEFT: 28px; POSITION: absolute; TOP: 713px; width: 601px;"
				runat="server" DataMember="Obywatelstwo.Nazwa" Height="28px" Text="Obywatelstwo &lt;.Normal&gt;(należy podać wszystkie obywatelstwa posiadane w dniu składania zgłoszenia)" 
                Number="29" CssClass="style1"></ea:framelabel>
<ea:framelabel id="Framelabel81" style="Z-INDEX: 170; LEFT: 0px; POSITION: absolute; TOP: 741px; height: 82px;"
				runat="server" Width="630px" 
                Text="B.2. INFORMACJA O NUMERACH IDENTYFIKACYJNYCH UZYSKANYCH W INNYCH KRAJACH&lt;/font&gt;&lt;br&gt;&lt;.Footer&gt;Wypełnić tylko wówczas, gdy składający uzyskał numery służące identyfikacji dla celów podatkowych lub ubezpieczeń społecznych w
                innych krajach. W przypadku braku miejsca na wpisanie dalszych informacji należy sporządzić listę tych informacji odpowiednio, zgodnie z zakresem danych określonych w części B.2. (poz. 30-32). Formularz składany za pomocą środków komunikacji elektronicznej obejmuje listę." 
                FrameStyle="BigYellow"></ea:framelabel>
<ea:framelabel id="Framelabel102" style="Z-INDEX: 171; LEFT: 28px; POSITION: absolute; TOP: 797px; width: 134px; right: 736px;"
				runat="server" DataMember="Obywatelstwo.KrajDokumentu" Height="28px" Text="Kraj" 
                Number="30"></ea:framelabel>
<ea:framelabel id="Framelabel84" style="Z-INDEX: 172; LEFT: 161px; POSITION: absolute; TOP: 797px; width: 166px;"
				runat="server" DataMember="Obywatelstwo.NumerPodatnika" Height="28px" Text="Numer" Number="31">
                </ea:frameLabel>
<ea:framelabel id="Framelabel41" style="Z-INDEX: 173; LEFT: 329px; POSITION: absolute; TOP: 797px; width: 300px; right: 736px;"
				runat="server" DataMember="" Height="28px" Text="Powód zgłoszenia (zaznaczyć właściwy kwadrat):" Number="32"></ea:framelabel>
<ea:checklabel id="p34_1" style="Z-INDEX: 174; LEFT: 360px; POSITION: absolute; TOP: 805px"
				runat="server" Width="136px" DataMember="" Height="14px" Text="numer aktualny" 
                Number="1" NumberAlignLeft="False"></ea:checkLabel>
<ea:checklabel id="p34_2" style="Z-INDEX: 175; LEFT: 460px; POSITION: absolute; TOP: 805px; right: 761px;"
				runat="server" Width="136px" DataMember="" Height="14px" Text="numer nieaktualny"
                Number="2" NumberAlignLeft="False"></ea:checkLabel>
<ea:framelabel id="FrameLabel182" style="Z-INDEX: 176; LEFT: 0px; POSITION: absolute; TOP: 830px; height: 21px;"
				runat="server" Width="630px" Text="1) Niniejszy formularz może być składany w charakterze zgłoszenia identyfikacyjnego lub zgłoszenia aktualizacyjnego.  W zgłoszeniu aktualizacyjnym&lt;br&gt;należy podać NIP składającego (poz.1)."
				FrameStyle="Small" FrameBorderStyle="None"></ea:framelabel>
<ea:framelabel id="FrameLabel183" style="Z-INDEX: 177; LEFT: 0px; POSITION: absolute; TOP: 850px; height: 21px;"
				runat="server" Width="630px" Text="2) Numer PESEL należy wypełnić wyłącznie w przypadku zgłoszenia identyfikacyjnego lub pierwszego zgłoszenia po uzyskaniu numeru PESEL."
				FrameStyle="Small" FrameBorderStyle="None"></ea:framelabel>
<ea:deklaracjafooter id="footer1" 
                style="Z-INDEX: 178; LEFT: 490px; POSITION: absolute; TOP: 930px" runat="server"
				Width="154px" Height="10px" TitleWidth="106" Symbol="NIP-7" PageNumber="1" 
                PageTotal="4" Version="3"></ea:deklaracjafooter>
<ea:deklaracjaheader id="DeklaracjaHeader2" style="Z-INDEX: 179; LEFT: 0px; POSITION: absolute; TOP: 980px"
				runat="server" Width="630px" StylNagłówka="WypałniaSkładającyCRP"></ea:deklaracjaheader>
<ea:framelabel id="Framelabel101" style="Z-INDEX: 180; LEFT: 0px; POSITION: absolute; TOP: 1001px; height: 108px;"
				runat="server" Width="630px" Text="B.3. ADRES MIEJSCA ZAMIESZKANIA" 
                FrameStyle="BigYellow"></ea:framelabel>
<ea:framelabel id="Framelabel106" style="Z-INDEX: 181; LEFT: 28px; POSITION: absolute; TOP: 1022px"
				runat="server" Width="140px" DataMember="Adres.Kraj" Height="28px" Text="Kraj" 
                Number="33" CssClass="style1"></ea:framelabel>
<ea:framelabel id="Framelabel107" style="Z-INDEX: 182; LEFT: 168px; POSITION: absolute; TOP: 1022px"
				runat="server" Width="266px" DataMember="Adres.Wojewodztwo" Height="28px" 
                Text="Województwo" Number="34"></ea:framelabel>
<ea:framelabel id="Framelabel108" style="Z-INDEX: 183; LEFT: 434px; POSITION: absolute; TOP: 1022px"
				runat="server" Width="196px" DataMember="Adres.Powiat" Height="28px" Text="Powiat" 
                Number="35"></ea:framelabel>
<ea:framelabel id="Framelabel109" style="Z-INDEX: 184; LEFT: 28px; POSITION: absolute; TOP: 1050px"
				runat="server" Width="161px" DataMember="Adres.Gmina" Height="28px" Text="Gmina" 
                Number="36"></ea:framelabel>
<ea:framelabel id="Framelabel110" style="Z-INDEX: 185; LEFT: 189px; POSITION: absolute; TOP: 1050px"
				runat="server" Width="301px" DataMember="Adres.Ulica" Height="28px" Text="Ulica" 
                Number="37"></ea:framelabel>
<ea:framelabel id="Framelabel111" style="Z-INDEX: 186; LEFT: 490px; POSITION: absolute; TOP: 1050px"
				runat="server" Width="70px" DataMember="Adres.NrDomu" Height="28px" Text="Nr domu" 
                Number="38"></ea:framelabel>
<ea:framelabel id="Framelabel112" style="Z-INDEX: 187; LEFT: 560px; POSITION: absolute; TOP: 1050px"
				runat="server" Width="70px" DataMember="Adres.NrLokalu" Height="28px" Text="Nr lokalu" 
                Number="39"></ea:framelabel>
<ea:framelabel id="Framelabel113" style="Z-INDEX: 188; LEFT: 28px; POSITION: absolute; TOP: 1078px; right: 639px;"
				runat="server" Width="252px" DataMember="Adres.Miejscowosc" Height="28px" Text="Miejscowość" 
                Number="40"></ea:framelabel>
<ea:framelabel id="Framelabel114" style="Z-INDEX: 189; LEFT: 280px; POSITION: absolute; TOP: 1078px; "
				runat="server" Width="105px" ValueStyle="PostalCode" DataMember="Adres.KodPocztowy" 
                Height="28px" Text="Kod pocztowy" Number="41" CssClass="style1"></ea:framelabel>
<ea:framelabel id="Framelabel115" style="Z-INDEX: 190; LEFT: 385px; POSITION: absolute; TOP: 1078px; height: 30px;"
				runat="server" Width="245px" DataMember="Adres.Poczta" Text="Poczta" Number="42"></ea:framelabel>
<ea:framelabel id="FrameLabel161" style="Z-INDEX: -1; LEFT: 0px; POSITION: absolute; TOP: 1106px; height: 90px;"
				runat="server" Width="630px" Text="B.4. DANE KONTAKTOWE&lt;/font&gt;&lt;br&gt;&lt;.Footer&gt;Podanie informacji w części B.4. nie jest obowiązkowe" FrameStyle="BigYellow"></ea:framelabel>
<ea:framelabel id="Framelabel163" style="Z-INDEX: 191; LEFT: 28px; POSITION: absolute; TOP: 1141px; width: 599px;"
				runat="server" DataMember="Adres.Telefon" Height="28px" Text="Telefon" 
                Number="43"></ea:framelabel>
<ea:framelabel id="Framelabel164" style="Z-INDEX: 192; LEFT: 28px; POSITION: absolute; TOP: 1169px; right: 632px; width: 258px;"
				runat="server" DataMember="Adres.Faks" Height="28px" Text="Faks" 
                Number="44"></ea:framelabel>
<ea:framelabel id="Framelabel165" style="Z-INDEX: 193; LEFT: 287px; POSITION: absolute; TOP: 1169px; right: 534px; width: 343px;"
				runat="server" DataMember="Kontakt.EMAIL" 
                Height="28px" Text="E-mail" Number="45"></ea:framelabel>
<ea:framelabel id="Framelabel14" style="Z-INDEX: 126; LEFT: 0px; POSITION: absolute; TOP: 1197px; height: 100px;"
				runat="server" Width="630px" Text="B.4.1. ADRES ELEKTRONICZNY&lt;/font&gt;&lt;.Footer&gt; - adres w systemie teleinformatycznym wykorzystywany odpowiednio przez organy podległe Ministrowi
                Finansów lub przez niego nadzorowane. Do doręczeń pism za pomocą środków komunikacji elektronicznej może mieć zastosowanie adres
                elektroniczny na <b>portalu podatkowym</b> (znany Administracji Podatkowej) lub w systemie ePUAP, w przypadku, jeżeli wniesiono o zastosowanie
                takiego sposobu doręczania albo wyrażono na to zgodę (art. 144a $ 1 pkt 2 lub art. 144a $ 1 pkt 3 w związku z art. 3e $ 1 ustawy - Ordynacja
                podatkowa). Adres elektroniczny w systemie ePUAP może mieć również zastosowanie do doręczeń pism w analogicznych przypadkach
                określonych w art. 39(1) $ 1 pkt 2 lub art. 39(1) $ 1 pkt 3 w związku z art. 39(1) $ 1a ustawy - Kodeks postępowania administracyjnego. W poz. 47
                można zaznaczyć rezygnację ze wskazania adresu elektronicznego." 
                FrameStyle="BigYellow"></ea:framelabel>
<ea:framelabel style="Z-INDEX: 137; LEFT: 28px; POSITION: absolute; TOP: 1267px; height: 30px; width: 401px;"
				runat="server" ID="AdresElektroniczny" Text="Adres elektroniczny" Number="46"></ea:framelabel>
<ea:framelabel style="Z-INDEX: 138; LEFT: 427px; POSITION: absolute; TOP: 1267px; right: 751px; width: 201px;"
				runat="server" ID="AdresElektronicznyRezyg" Height="28px" Text="Rezygnacja z adresu elektronicznego" Number="47"></ea:framelabel>
<ea:checklabel id="checkAdresElektronicznyRezyg" style="Z-INDEX: 145; LEFT: 517px; POSITION: absolute; TOP: 1276px; right: 382px;"
				runat="server" Width="35px" Height="14px"></ea:checklabel>
<ea:framelabel id="Framelabel59" style="Z-INDEX: 126; LEFT: 0px; POSITION: absolute; TOP: 1295px; height: 128px;"
				runat="server" Width="630px" Text="B.4.2. ADRES DO KORESPONDENCJI&lt;/font&gt;&lt;br&gt;&lt;.Footer&gt;Należy wypełnić tylko wówczas, gdy adres do korespondencji
                jest inny niż w części B.3." 
                FrameStyle="BigYellow" FrameBorderStyle="DoubleBottom"></ea:framelabel>
<ea:framelabel style="Z-INDEX: 127; LEFT: 28px; POSITION: absolute; TOP: 1330px"
				runat="server" Width="140px" ID="AdresKrajK" Height="28px" Text="Kraj" 
                Number="48" CssClass="style1"></ea:framelabel>
<ea:framelabel style="Z-INDEX: 128; LEFT: 168px; POSITION: absolute; TOP: 1330px"
				runat="server" Width="266px" ID="AdresWojewodztwoK" Height="28px" 
                Text="Województwo" Number="49"></ea:framelabel>
<ea:framelabel style="Z-INDEX: 129; LEFT: 434px; POSITION: absolute; TOP: 1330px"
				runat="server" Width="196px" ID="AdresPowiatK" Height="28px" Text="Powiat" 
                Number="50"></ea:framelabel>
<ea:framelabel style="Z-INDEX: 130; LEFT: 28px; POSITION: absolute; TOP: 1358px"
				runat="server" Width="161px" ID="AdresGminaK" Height="28px" Text="Gmina" 
                Number="51"></ea:framelabel>
<ea:framelabel style="Z-INDEX: 131; LEFT: 189px; POSITION: absolute; TOP: 1358px"
				runat="server" Width="301px" ID="AdresUlicaK" Height="28px" Text="Ulica" 
                Number="52"></ea:framelabel>
<ea:framelabel style="Z-INDEX: 132; LEFT: 490px; POSITION: absolute; TOP: 1358px"
				runat="server" Width="70px" ID="AdresNrDomuK" Height="28px" Text="Nr domu" 
                Number="53"></ea:framelabel>
<ea:framelabel style="Z-INDEX: 133; LEFT: 560px; POSITION: absolute; TOP: 1358px"
				runat="server" Width="70px" ID="AdresNrLokaluK" Height="28px" Text="Nr lokalu" 
                Number="54"></ea:framelabel>
<ea:framelabel style="Z-INDEX: 134; LEFT: 28px; POSITION: absolute; TOP: 1386px; right: 639px;"
				runat="server" Width="252px" ID="AdresMiejscowoscK" Height="28px" Text="Miejscowość" 
                Number="55"></ea:framelabel>
<ea:framelabel style="Z-INDEX: 135; LEFT: 280px; POSITION: absolute; TOP: 1386px; "
				runat="server" Width="105px" ValueStyle="PostalCode" ID="AdresKodPocztowyK" 
                Height="28px" Text="Kod pocztowy" Number="56" CssClass="style1"></ea:framelabel>
<ea:framelabel style="Z-INDEX: 136; LEFT: 385px; POSITION: absolute; TOP: 1386px; height: 30px;"
				runat="server" Width="245px" ID="AdresPocztaK" Text="Poczta" Number="57"></ea:framelabel>
<ea:framelabel id="FrameLabel16" style="Z-INDEX: 200; LEFT: 0px; POSITION: absolute; TOP: 1421px"
				runat="server" Width="630px" Height="32px" Text="C. DANE DOTYCZĄCE PROWADZONEJ SAMODZIELNIE DZIAŁALNOŚCI GOSPODARCZEJ&lt;/font&gt;&lt;.Footer&gt;(w zakresie zgodnym z opisem przeznaczenia formularza)" 
                FrameStyle="BigYellowBold"></ea:framelabel>
<ea:framelabel id="FrameLabel43" style="Z-INDEX: 201; LEFT: 0px; POSITION: absolute; TOP: 1456px; height: 198px;"
				runat="server" Width="630px" Text="C.1. DATY DOTYCZĄCE PROWADZONEJ DZIAŁALNOŚCI, NUMER IDENTYFIKACYJNY REGON, RODZAJ DZIAŁALNOŚCI, STATUS SZCZEGÓLNY"
                FrameStyle="BigYellow"></ea:framelabel>
<ea:framelabel id="Framelabel44" style="Z-INDEX: 202; LEFT: 28px; POSITION: absolute; TOP: 1491px; width: 330px;"
				runat="server" Height="28px" Text="Rodzaj daty (zaznaczyć właściwy kwadrat):" 
                Number="58"></ea:framelabel>
<ea:checklabel id="p53_1" style="Z-INDEX: 203; LEFT: 43px; POSITION: absolute; TOP: 1498px; right: 382px;"
				runat="server" Width="130px" Text="rozpoczęcie działalności" Height="14px"
                Number="1" NumberAlignLeft="False"></ea:checklabel>
<ea:checklabel id="p53_2" style="Z-INDEX: 203; LEFT: 183px; POSITION: absolute; TOP: 1498px; right: 382px;"
				runat="server" Width="130px" Text="zakończenie działalności" Height="14px"
                Number="2" NumberAlignLeft="False"></ea:checklabel>
<ea:framelabel id="Framelabel45" style="Z-INDEX: 204; LEFT: 357px; POSITION: absolute; TOP: 1491px; width: 270px;"
				runat="server" Height="28px" Text="Data" ValueStyle="Date" Number="59"></ea:framelabel>
<ea:framelabel id="Framelabel46" style="Z-INDEX: 205; LEFT: 28px; POSITION: absolute; TOP: 1519px; width: 601px;"
				runat="server" Height="28px" Text="Numer identyfikacyjny REGON" Number="60"></ea:framelabel>
<ea:framelabel id="Framelabel47" style="Z-INDEX: 206; LEFT: 28px; POSITION: absolute; TOP: 1547px; width: 500px;"
				runat="server" Height="80px" Text="Rodzaj przeważającej działalności (należy podać rodzaj przeważającej działalności gospodarczej, w przypadku
                rozpoczynających - rodzaj planowanej działalności, według Polskiej Klasyfikacji Działalności (PKD)) &lt;.INDEXUP&gt;3)"
                Number="61"></ea:framelabel>
<ea:framelabel id="Framelabel48" style="Z-INDEX: 207; LEFT: 525px; POSITION: absolute; TOP: 1547px; width: 105px;"
				runat="server" Height="80px" Text="Kod PKD" Number="62"></ea:framelabel>
<ea:framelabel id="Framelabel49" style="Z-INDEX: 208; LEFT: 28px; POSITION: absolute; TOP: 1624px; width: 601px;"
				runat="server" Height="28px" Text="Status szczególny działalności (zaznaczyć właściwe kwadraty):"
                Number="63"></ea:framelabel>
<ea:checklabel id="p58_1" style="Z-INDEX: 209; LEFT: 43px; POSITION: absolute; TOP: 1631px; right: 382px;"
				runat="server" Width="180px" Text="prowadzi zakład pracy chronionej" Height="14px"
                Number="1" NumberAlignLeft="False"></ea:checklabel>
<ea:checklabel id="p58_2" style="Z-INDEX: 210; LEFT: 197px; POSITION: absolute; TOP: 1631px; right: 382px;"
				runat="server" Width="180px" Text="nie prowadzi zakładu pracy chronionej" Height="14px"
                Number="2" NumberAlignLeft="False"></ea:checklabel>
<ea:checklabel id="p58_3" style="Z-INDEX: 211; LEFT: 368px; POSITION: absolute; TOP: 1631px; right: 382px;"
				runat="server" Width="280px" Text="prowadzi zagraniczne przedsiębiorstwo drobnej wytwórczości" Height="14px"
                Number="3" NumberAlignLeft="False"></ea:checklabel>
<ea:framelabel id="FrameLabel80" style="Z-INDEX: 254; LEFT: 0px; POSITION: absolute; TOP: 1652px"
				runat="server" Width="630px" Height="130px" Text="C.2. DANE WYNIKAJĄCE Z WPISU DO EWIDENCJI LUB REJESTRU" 
                FrameStyle="BigYellow"></ea:framelabel>
<ea:framelabel id="Framelabel97" style="Z-INDEX: 258; LEFT: 28px; POSITION: absolute; TOP: 1673px; height: 28px;"
				runat="server" Width="599px" Text="Nazwa pełna" Number="64">
                </ea:framelabel>
<ea:framelabel id="Framelabel93" style="Z-INDEX: 255; LEFT: 28px; POSITION: absolute; TOP: 1701px; height: 28px;"
				runat="server" Width="599px" Text="Nazwa organu prowadzącego ewidencję lub rejestr" Number="65">
                </ea:framelabel>
<ea:framelabel id="Framelabel94" style="Z-INDEX: 256; LEFT: 28px; POSITION: absolute; TOP: 1729px; height: 28px;"
				runat="server" Width="599px" Text="Nazwa ewidencji lub rejestru" Number="66">
                </ea:framelabel>
<ea:framelabel id="Framelabel95" style="Z-INDEX: 257; LEFT: 28px; POSITION: absolute; TOP: 1757px; height: 28px;"
				runat="server" Width="300px" Text="Data rejestracji lub data zmiany" Number="67" ValueStyle="Date">
                </ea:framelabel>
<ea:framelabel id="Framelabel96" style="Z-INDEX: 257; LEFT: 329px; POSITION: absolute; TOP: 1757px; height: 28px;"
				runat="server" Width="298px" Text="Numer w ewidencji lub w rejestrze" Number="68">
                </ea:framelabel>
<ea:framelabel id="FrameLabel51" style="Z-INDEX: 212; LEFT: 0px; POSITION: absolute; TOP: 1790px; height: 50px;"
				runat="server" Width="630px" Text="3) Przeważającą działalność ustala się zgodnie z $10 ust.2 rozporządzenia Rady Ministrów z dnia 27 lipca 1999 r. w sprawie sposobu i metodologii
                prowadzenia i aktualizacji rejestru podmiotów gospodarki narodowej, w tym wzorów wniosków, ankiet i zaświadczeń oraz szczegółowych
                warunków i trybu współdziałania służb statystyki publicznej z innymi organami prowadzącymi urzędowe rejestry i systemy informacyjne
                administracji publicznej (Dz.U. Nr 69, poz.763, z późn.zm.).&lt;br&gt;
                Klasyfikacja PKD dostępna jest na stronie internetowej Głównego Urzędu Statystycznego www.stat.gov.pl"
				FrameStyle="Small" FrameBorderStyle="None"></ea:framelabel>
<ea:deklaracjafooter id="footer2" 
                style="Z-INDEX: 213; LEFT: 0px; POSITION: absolute; TOP: 1900px" runat="server"
				Width="154px" Height="10px" TitleWidth="106" Symbol="NIP-7" PageNumber="2" 
                PageTotal="4" Version="3"></ea:deklaracjafooter>
<ea:deklaracjaheader id="DeklaracjaHeader3" style="Z-INDEX: 214; LEFT: 0px; POSITION: absolute; TOP: 1960px"
				runat="server" Width="630px" StylNagłówka="WypałniaSkładającyCRP"></ea:deklaracjaheader>
<ea:framelabel id="FrameLabel98" style="Z-INDEX: 261; LEFT: 0px; POSITION: absolute; TOP: 1983px"
				runat="server" Width="630px" Height="30px" Text="C.3. ADRESY MIEJSC PROWADZENIA DZIAŁALNOŚCI" 
                FrameStyle="BigYellowBold"></ea:framelabel>
<ea:framelabel id="FrameLabel125" style="Z-INDEX: -1; LEFT: 0px; POSITION: absolute; TOP: 2008px; height: 118px; right: 289px;"
				runat="server" Width="630px" Text="C.3.1. ADRES GŁÓWNEGO MIEJSCA PROWADZENIA DZIAŁALNOŚCI&lt;br&gt;&lt;/font&gt;&lt;.Footer&gt;Jeżeli nie jest możliwe wskazanie adresu głównego miejsca prowadzenia działalności, należy podać adres zamieszkania." 
                FrameStyle="BigYellow"></ea:framelabel>
<ea:framelabel id="Framelabel99" style="Z-INDEX: 264; LEFT: 28px; POSITION: absolute; TOP: 2043px"
				runat="server" Width="140px" Height="28px" Text="Kraj" 
                Number="69"></ea:framelabel>
<ea:framelabel id="Framelabel100" style="Z-INDEX: 265; LEFT: 168px; POSITION: absolute; TOP: 2043px"
				runat="server" Width="266px" Height="28px" 
                Text="Województwo" Number="70"></ea:framelabel>
<ea:framelabel id="Framelabel104" style="Z-INDEX: 266; LEFT: 434px; POSITION: absolute; TOP: 2043px"
				runat="server" Width="196px" Height="28px" Text="Powiat" 
                Number="71"></ea:framelabel>
<ea:framelabel id="Framelabel116" style="Z-INDEX: 267; LEFT: 28px; POSITION: absolute; TOP: 2071px"
				runat="server" Width="161px" Height="28px" Text="Gmina" 
                Number="72"></ea:framelabel>
<ea:framelabel id="Framelabel117" style="Z-INDEX: 268; LEFT: 189px; POSITION: absolute; TOP: 2071px"
				runat="server" Width="301px" Height="28px" Text="Ulica" 
                Number="73"></ea:framelabel>
<ea:framelabel id="Framelabel118" style="Z-INDEX: 269; LEFT: 490px; POSITION: absolute; TOP: 2071px"
				runat="server" Width="70px" Height="28px" Text="Nr domu" 
                Number="74"></ea:framelabel>
<ea:framelabel id="Framelabel119" style="Z-INDEX: 270; LEFT: 560px; POSITION: absolute; TOP: 2071px"
				runat="server" Width="70px" Height="28px" Text="Nr lokalu" 
                Number="75"></ea:framelabel>
<ea:framelabel id="Framelabel120" style="Z-INDEX: 271; LEFT: 28px; POSITION: absolute; TOP: 2099px; right: 639px;"
				runat="server" Width="252px" Height="28px" Text="Miejscowość" 
                Number="76"></ea:framelabel>
<ea:framelabel id="Framelabel122" style="Z-INDEX: 272; LEFT: 280px; POSITION: absolute; TOP: 2099px; "
				runat="server" Width="105px" ValueStyle="PostalCode" 
                Height="28px" Text="Kod pocztowy" Number="77"></ea:framelabel>
<ea:framelabel id="Framelabel123" style="Z-INDEX: 273; LEFT: 385px; POSITION: absolute; TOP: 2099px; height: 30px;"
				runat="server" Width="245px" Text="Poczta" Number="78"></ea:framelabel>
<ea:framelabel id="FrameLabel126" style="Z-INDEX: -1; LEFT: 0px; POSITION: absolute; TOP: 2127px; height: 210px; right: 289px;"
				runat="server" Width="630px" Text="C.3.2. ADRESY POZOSTAŁYCH MIEJSC PROWADZENIA DZIAŁALNOŚCI&lt;br&gt;&lt;/font&gt;&lt;.Footer&gt;W zgłoszeniu identyfikacyjnym podać adresy wszystkich miejsc prowadzenia działalności (również hurtowni, magazynów, składów), a w zgłoszeniu
                aktualizacyjnym stosownie do okoliczności i zmian. W przypadku braku miejsca na wpisanie dalszych adresów należy sporządzić listę adresów tych miejsc odpowiednio, zgodnie z zakresem części C.3.2. (poz.79-90).
                Formularz składany za pomocą środków komunikacji elektronicznej obejmuje listę. W przypadku adresu nietypowego (np. sklep w przejściu podziemnym, działalność na terenie całego kraju) dane adresowe należy podać z możliwą dokładnością." 
                FrameStyle="BigYellow" FrameBorderStyle="DoubleBottom"></ea:framelabel>
<ea:framelabel id="Framelabel131" style="Z-INDEX: 274; LEFT: 28px; POSITION: absolute; TOP: 2190px"
				runat="server" Width="599px" Height="28px" Text="Powód zgłoszenia adresu (zaznaczyć właściwy kwadrat):" 
                Number="79"></ea:framelabel>
<ea:checklabel id="p104_1" style="Z-INDEX: 275; LEFT: 50px; POSITION: absolute; TOP: 2197px; right: 382px;"
				runat="server" Width="250px" Text="prowadzenie działalności pod tym adresem"
                Number="1" NumberAlignLeft="False" Height="14px"></ea:checklabel>
<ea:checklabel id="p104_2" style="Z-INDEX: 276; LEFT: 320px; POSITION: absolute; TOP: 2197px; right: 382px;"
				runat="server" Width="250px" Text="zakończenie działalności pod tym adresem"
                Number="2" NumberAlignLeft="False" Height="14px"></ea:checklabel>
<ea:framelabel id="Framelabel132" style="Z-INDEX: 277; LEFT: 28px; POSITION: absolute; TOP: 2218px"
				runat="server" Width="140px" Height="28px" Text="Kraj" 
                Number="80"></ea:framelabel>
<ea:framelabel id="Framelabel133" style="Z-INDEX: 278; LEFT: 168px; POSITION: absolute; TOP: 2218px"
				runat="server" Width="266px" Height="28px" 
                Text="Województwo" Number="81"></ea:framelabel>
<ea:framelabel id="Framelabel134" style="Z-INDEX: 279; LEFT: 434px; POSITION: absolute; TOP: 2218px"
				runat="server" Width="196px" Height="28px" Text="Powiat" 
                Number="82"></ea:framelabel>
<ea:framelabel id="Framelabel135" style="Z-INDEX: 280; LEFT: 28px; POSITION: absolute; TOP: 2246px"
				runat="server" Width="161px" Height="28px" Text="Gmina" 
                Number="83"></ea:framelabel>
<ea:framelabel id="Framelabel138" style="Z-INDEX: 281; LEFT: 189px; POSITION: absolute; TOP: 2246px"
				runat="server" Width="301px" Height="28px" Text="Ulica" 
                Number="84"></ea:framelabel>
<ea:framelabel id="Framelabel139" style="Z-INDEX: 282; LEFT: 490px; POSITION: absolute; TOP: 2246px"
				runat="server" Width="70px" Height="28px" Text="Nr domu" 
                Number="85"></ea:framelabel>
<ea:framelabel id="Framelabel140" style="Z-INDEX: 283; LEFT: 560px; POSITION: absolute; TOP: 2246px"
				runat="server" Width="70px" Height="28px" Text="Nr lokalu" 
                Number="86"></ea:framelabel>
<ea:framelabel id="Framelabel141" style="Z-INDEX: 284; LEFT: 28px; POSITION: absolute; TOP: 2274px; right: 639px;"
				runat="server" Width="252px" Height="28px" Text="Miejscowość" 
                Number="87"></ea:framelabel>
<ea:framelabel id="Framelabel142" style="Z-INDEX: 285; LEFT: 280px; POSITION: absolute; TOP: 2274px; "
				runat="server" Width="105px" ValueStyle="PostalCode" 
                Height="28px" Text="Kod pocztowy" Number="88"></ea:framelabel>
<ea:framelabel id="Framelabel143" style="Z-INDEX: 286; LEFT: 385px; POSITION: absolute; TOP: 2274px; height: 30px;"
				runat="server" Width="245px" Text="Poczta" Number="89"></ea:framelabel>
<ea:framelabel id="Framelabel144" style="Z-INDEX: 287; LEFT: 28px; POSITION: absolute; TOP: 2302px; height: 30px;"
				runat="server" Width="599px" Text="Określenie opisowe adresu nietypowego" Number="90"></ea:framelabel>
<ea:framelabel id="FrameLabel79" style="Z-INDEX: -1; LEFT: 0px; POSITION: absolute; TOP: 2337px; height: 120px; right: 289px;"
				runat="server" Width="630px" Text="C.4. ADRES MIEJSCA PRZECHOWYWANIA DOKUMENTACJI RACHUNKOWEJ" 
                FrameStyle="BigYellow" FrameBorderStyle="DoubleBottom"></ea:framelabel>
<ea:framelabel id="Framelabel82" style="Z-INDEX: 244; LEFT: 28px; POSITION: absolute; TOP: 2365px"
				runat="server" Width="140px" Height="28px" Text="Kraj" 
                Number="91" CssClass="style1"></ea:framelabel>
<ea:framelabel id="Framelabel83" style="Z-INDEX: 245; LEFT: 168px; POSITION: absolute; TOP: 2365px"
				runat="server" Width="266px" Height="28px" 
                Text="Województwo" Number="92"></ea:framelabel>
<ea:framelabel id="Framelabel85" style="Z-INDEX: 246; LEFT: 434px; POSITION: absolute; TOP: 2365px"
				runat="server" Width="196px" Height="28px" Text="Powiat" 
                Number="93"></ea:framelabel>
<ea:framelabel id="Framelabel86" style="Z-INDEX: 247; LEFT: 28px; POSITION: absolute; TOP: 2393px"
				runat="server" Width="161px" Height="28px" Text="Gmina" 
                Number="94"></ea:framelabel>
<ea:framelabel id="Framelabel87" style="Z-INDEX: 248; LEFT: 189px; POSITION: absolute; TOP: 2393px"
				runat="server" Width="301px" Height="28px" Text="Ulica" 
                Number="95"></ea:framelabel>
<ea:framelabel id="Framelabel88" style="Z-INDEX: 249; LEFT: 490px; POSITION: absolute; TOP: 2393px"
				runat="server" Width="70px" Height="28px" Text="Nr domu" 
                Number="96"></ea:framelabel>
<ea:framelabel id="Framelabel89" style="Z-INDEX: 250; LEFT: 560px; POSITION: absolute; TOP: 2393px"
				runat="server" Width="70px" Height="28px" Text="Nr lokalu" 
                Number="97"></ea:framelabel>
<ea:framelabel id="Framelabel90" style="Z-INDEX: 251; LEFT: 28px; POSITION: absolute; TOP: 2421px; right: 639px;"
				runat="server" Width="252px" Height="28px" Text="Miejscowość" 
                Number="98"></ea:framelabel>
<ea:framelabel id="Framelabel91" style="Z-INDEX: 252; LEFT: 280px; POSITION: absolute; TOP: 2421px; "
				runat="server" Width="105px" ValueStyle="PostalCode" 
                Height="28px" Text="Kod pocztowy" Number="99" CssClass="style1"></ea:framelabel>
<ea:framelabel id="Framelabel92" style="Z-INDEX: 253; LEFT: 385px; POSITION: absolute; TOP: 2421px; height: 30px;"
				runat="server" Width="245px" Text="Poczta" Number="100"></ea:framelabel>
<ea:framelabel id="FrameLabel56" style="Z-INDEX: 215; LEFT: 0px; POSITION: absolute; TOP: 2457px"
				runat="server" Width="630px" Height="32px" Text="D. INFORMACJE DOTYCZĄCE RACHUNKÓW&lt;/font&gt;&lt;br&gt;&lt;.Footer&gt;Kraj siedziby banku (oddziału) należy podać, gdy rachunek jest prowadzony za granicą." 
                FrameStyle="BigYellowBold"></ea:framelabel>
<ea:framelabel id="FrameLabel162" style="Z-INDEX: -1; LEFT: 0px; POSITION: absolute; TOP: 2490px; height: 166px; right: 289px;"
				runat="server" Width="630px" Text="D.1. RACHUNEK OSOBISTY - DO ZWROTU PODATKU LUB NADPŁATY&lt;/font&gt;&lt;br&gt;&lt;.Footer&gt;Podanie informacji o rachunku (poz. 101-104) nie jest obowiązkowe, jeżeli składający nie wybiera tej formy zwrotu podatku lub nadpłaty. Na wskazany rachunek będą dokonywane ewentualne zwroty nadpłaty lub podatku. Można podać jedynie taki rachunek, którego właścicielem lub współwłaścicielem jest składający. Wpisane niżej dane dotyczące rachunku aktualizują poprzedni stan danych. W przypadku zgłoszenia aktualizacyjnego, jeżeli dane zawarte w części D.1 nie zmieniły się, to część D.1 formularza nie musi być wypełniona. Zaznaczenie kwadratu w poz.105 oznacza rezygnację przez składającego 
                z otrzymywania ewentualnego zwrotu nadpłaty lub podatku na rachunek osobisty (również z powodu likwidacji rachunku)." 
                FrameStyle="BigYellow" FrameBorderStyle="DoubleBottom"></ea:framelabel>
<ea:framelabel id="rachunekKraj" style="Z-INDEX: 194; LEFT: 28px; POSITION: absolute; TOP: 2567px; right: 632px; width: 258px;"
				runat="server" Height="28px" Text="Kraj siedziby banku (oddziału)" 
                Number="101"></ea:framelabel>
<ea:framelabel id="rachunekNazwaBanku" style="Z-INDEX: 195; LEFT: 287px; POSITION: absolute; TOP: 2567px; right: 534px; width: 343px;"
				runat="server" 
                Height="28px" Text="Pełna nazwa banku (oddziału) / SKOK" Number="102"></ea:framelabel>
<ea:framelabel id="rachunekPosiadacz" style="Z-INDEX: 196; LEFT: 28px; POSITION: absolute; TOP: 2595px; width: 599px;"
				runat="server" Height="28px" Text="Posiadacz rachunku" 
                Number="103"></ea:framelabel>
<ea:framelabel id="rachunekNumer" style="Z-INDEX: 197; LEFT: 28px; POSITION: absolute; TOP: 2623px; width: 500px;"
				runat="server" Height="28px" Text="Pełny numer rachunku (w przypadku rachunku zagranicznego numer rachunku powinien zawierać kod SWIFT)" 
                Number="104"></ea:framelabel>
<ea:framelabel style="Z-INDEX: 198; LEFT: 525px; POSITION: absolute; TOP: 2623px"
				runat="server" Width="105px" Height="28px" Text="Rezygnacja" 
                Number="105"></ea:framelabel>
<ea:checklabel id="rachunekRezygnacja" style="Z-INDEX: 199; LEFT: 565px; POSITION: absolute; TOP: 2632px; right: 382px;"
				runat="server" Width="35px" Height="14px"></ea:checklabel>
<ea:framelabel id="FrameLabel65" style="Z-INDEX: -1; LEFT: 0px; POSITION: absolute; TOP: 2651px; height: 44px; right: 289px;"
				runat="server" Width="630px" Text="D.2. RACHUNKI ZWIĄZANE Z PROWADZONĄ DZIAŁALNOŚCIĄ&lt;/font&gt;&lt;br&gt;&lt;.Footer&gt;W przypadku braku miejsca na wpisanie wszystkich rachunków sporządzić listę tych rachunków odpowiednio, zgodnie z zakresem danych określonych w części D.2.2. (poz. 111-115). Formularz składany za pomocą środków komunikacji elektronicznej obejmuje listę." 
                FrameStyle="BigYellow" ></ea:framelabel>
<ea:framelabel id="FrameLabel50" style="Z-INDEX: -1; LEFT: 0px; POSITION: absolute; TOP: 2693px; height: 170px; right: 289px;"
				runat="server" Width="630px" Text="D.2.1. RACHUNEK DO ZWROTU PODATKU LUB NADPŁATY&lt;/font&gt;&lt;br&gt;&lt;.Footer&gt;W przypadku gdy następuje zmiana rachunku do zwrotu podatku lub nadpłaty, w poz.110 podać numer rachunku poprzednio wskazanego do zwrotu podatku lub nadpłaty." 
                FrameStyle="BigYellow"></ea:framelabel>
<ea:framelabel id="Framelabel52" style="Z-INDEX: 216; LEFT: 28px; POSITION: absolute; TOP: 2728px; right: 632px; width: 258px;"
				runat="server" Height="28px" Text="Kraj siedziby banku (oddziału)" 
                Number="106"></ea:framelabel>
<ea:framelabel id="Framelabel53" style="Z-INDEX: 217; LEFT: 287px; POSITION: absolute; TOP: 2728px; right: 534px; width: 343px;"
				runat="server" 
                Height="28px" Text="Pełna nazwa banku (oddziału) / SKOK" Number="107"></ea:framelabel>
<ea:framelabel id="Framelabel54" style="Z-INDEX: 218; LEFT: 28px; POSITION: absolute; TOP: 2756px; width: 599px;"
				runat="server" Height="28px" Text="Posiadacz rachunku" 
                Number="108"></ea:framelabel>
<ea:framelabel id="Framelabel55" style="Z-INDEX: 219; LEFT: 28px; POSITION: absolute; TOP: 2784px; width: 599px;"
				runat="server" Height="28px" Text="Pełny numer rachunku (w przypadku rachunku zagranicznego numer rachunku powinien zawierać kod SWIFT)" 
                Number="109"></ea:framelabel>
<ea:framelabel id="Framelabel57" style="Z-INDEX: 220; LEFT: 28px; POSITION: absolute; TOP: 2812px; width: 599px;"
				runat="server" Height="48px" Text="Numer rachunku poprzednio wskazanego do zwrotu podatku lub nadpłaty (w przypadku rachunku zagranicznego numer rachunku powinien zawierać kod SWIFT)" 
                Number="110"></ea:framelabel>
<ea:deklaracjafooter id="footer3" 
                style="Z-INDEX: 259; LEFT: 490px; POSITION: absolute; TOP: 2870px" runat="server"
				Width="154px" Height="10px" TitleWidth="106" Symbol="NIP-7" PageNumber="3" 
                PageTotal="4" Version="3"></ea:deklaracjafooter>
<ea:deklaracjaheader id="DeklaracjaHeader4" style="Z-INDEX: 260; LEFT: 0px; POSITION: absolute; TOP: 2940px"
				runat="server" Width="630px" StylNagłówka="WypałniaSkładającyCRP"></ea:deklaracjaheader>
<ea:framelabel id="FrameLabel66" style="Z-INDEX: -1; LEFT: 0px; POSITION: absolute; TOP: 2962px; height: 112px; right: 289px;"
				runat="server" Width="630px" Text="D.2.2. POZOSTAŁE RACHUNKI ZWIĄZANE Z PROWADZONĄ DZIAŁALNOŚCIĄ" 
                FrameStyle="BigYellow" FrameBorderStyle="DoubleBottom"></ea:framelabel>
<ea:framelabel id="Framelabel67" style="Z-INDEX: 194; LEFT: 28px; POSITION: absolute; TOP: 2983px; right: 632px; width: 258px;"
				runat="server" Height="28px" Text="Kraj siedziby banku (oddziału)" 
                Number="111"></ea:framelabel>
<ea:framelabel id="Framelabel68" style="Z-INDEX: 195; LEFT: 287px; POSITION: absolute; TOP: 2983px; right: 534px; width: 343px;"
				runat="server" 
                Height="28px" Text="Pełna nazwa banku (oddziału) / SKOK" Number="112"></ea:framelabel>
<ea:framelabel id="Framelabel69" style="Z-INDEX: 196; LEFT: 28px; POSITION: absolute; TOP: 3011px; width: 599px;"
				runat="server" Height="28px" Text="Posiadacz rachunku" 
                Number="113"></ea:framelabel>
<ea:framelabel id="Framelabel70" style="Z-INDEX: 197; LEFT: 28px; POSITION: absolute; TOP: 3039px; width: 480px;"
				runat="server" Height="28px" Text="Pełny numer rachunku (w przypadku rachunku zagranicznego numer rachunku powinien zawierać kod SWIFT)" 
                Number="114"></ea:framelabel>
<ea:framelabel style="Z-INDEX: 198; LEFT: 504px; POSITION: absolute; TOP: 3039px"
				runat="server" Width="124px" Height="28px" Text="Likwidacja rachunku" 
                Number="115"></ea:framelabel>
<ea:checklabel id="p115" style="Z-INDEX: 199; LEFT: 565px; POSITION: absolute; TOP: 3048px; right: 382px;"
				runat="server" Width="35px" Height="14px"></ea:checklabel>
<ea:framelabel id="FrameLabel145" style="Z-INDEX: 288; LEFT: 0px; POSITION: absolute; TOP: 3075px"
				runat="server" Width="630px" Height="78px" Text="E. INFORMACJA O ZAŁĄCZNIKACH&lt;/font&gt;&lt;br&gt;&lt;.Footer&gt;W poz. 116 wskazać dołączone listy. Składając formularz za pomocą środków komunikacji elektronicznej pominąć poz. 116. W poz. 117 zaznaczyć dołączone dokumenty albo ich uwierzytelnione lub poświadczone urzędowo kopie (art. 5 ust. 4a i art. 9 ust. 6 pkt 1 ustawy)." 
                FrameStyle="BigYellowBold" FrameBorderStyle="DoubleBottom"></ea:framelabel>
<ea:framelabel id="Framelabel149" style="Z-INDEX: 290; LEFT: 28px; POSITION: absolute; TOP: 3117px; height: 30px;"
				runat="server" Width="300px" Text="Lista, o której mowa w części: (zaznaczyć właściwe kwadraty):" Number="116"></ea:framelabel>
<ea:framelabel id="Framelabel150" style="Z-INDEX: 291; LEFT: 329px; POSITION: absolute; TOP: 3117px; height: 30px;"
				runat="server" Width="300px" Text="Dołączone dokumenty (zaznaczyć właściwy kwadrat):" Number="117"></ea:framelabel>
<ea:checklabel id="p116_1" style="Z-INDEX: 295; LEFT: 50px; POSITION: absolute; TOP: 3126px; right: 382px;"
				runat="server" Width="50px" Text="B.2."
                NumberAlignLeft="False" Height="14px"></ea:checklabel>
<ea:checklabel id="p116_2" style="Z-INDEX: 295; LEFT: 100px; POSITION: absolute; TOP: 3126px; right: 382px;"
				runat="server" Width="50px" Text="C.3.2."
                NumberAlignLeft="False" Height="14px"></ea:checklabel>
<ea:checklabel id="p116_3" style="Z-INDEX: 295; LEFT: 150px; POSITION: absolute; TOP: 3126px; right: 382px;"
				runat="server" Width="50px" Text="D.2."
                NumberAlignLeft="False" Height="14px"></ea:checklabel>
<ea:checklabel id="p117_1" style="Z-INDEX: 295; LEFT: 340px; POSITION: absolute; TOP: 3126px; right: 382px;"
				Number="1" runat="server" Width="50px" Text="pełnomocnictwo"
                NumberAlignLeft="False" Height="14px"></ea:checklabel>
<ea:checklabel id="p118_2" style="Z-INDEX: 295; LEFT: 430px; POSITION: absolute; TOP: 3126px; right: 382px;"
				Number="2" runat="server" Width="200px" Text="postanowienie sądu o ustanowieniu kuratora"
                NumberAlignLeft="False" Height="14px"></ea:checklabel>
<ea:framelabel id="Framelabel121" style="Z-INDEX: 251; LEFT: 0px; POSITION: absolute; TOP: 3150px; width: 630px; height: 188px;"
				runat="server" 
                Text="F. &lt;font size=2&gt;PODPIS SKŁADAJĄCEGO/DANE I PODPIS OSOBY REPREZENTUJĄCEJ SKŁADAJĄCEGO&lt;/font&gt;&lt;br&gt;&lt;.Footer&gt;Poz.118-121 wypełnia wyłącznie osoba reprezentująca składającego, tj. osoba posiadająca pełnomocnictwo albo postanowienie sądu. Wymóg opatrzenia zgłoszenia pieczątką nie dotyczy formularzy składanych za pomocą środków komunikacji elektronicznej." 
                FrameStyle="BigYellowBold" FrameBorderStyle="DoubleBottom"></ea:framelabel>
<ea:framelabel id="Framelabel177" style="Z-INDEX: 252; LEFT: 28px; POSITION: absolute; TOP: 3192px; width: 300px;"
				runat="server" Height="28px" DataMember="Imie" Text="Imię" Number="118"></ea:framelabel>
<ea:framelabel id="Framelabel181" style="Z-INDEX: 253; LEFT: 329px; POSITION: absolute; TOP: 3192px; width: 300px; right: 485px;"
				runat="server" Height="28px" DataMember="Nazwisko"  Text="Nazwisko" Number="119"></ea:framelabel>
<ea:framelabel id="Framelabel178" style="Z-INDEX: 254; LEFT: 28px; POSITION: absolute; TOP: 3220px; width: 599px;"
				runat="server" Height="28px" Text="Identyfikator podatkowy NIP / numer PESEL&lt;.INDEXUP&gt;(niepotrzebne skreślić)" Number="120"></ea:framelabel>
<ea:framelabel id="Framelabel166" style="Z-INDEX: 255; LEFT: 28px; POSITION: absolute; TOP: 3248px; right: 632px; width: 599px;"
				runat="server" Height="28px" DataMember="AdresDoKorespondencji.Pełny" Text="Adres do korespondencji" 
                Number="121"></ea:framelabel>
<ea:framelabel id="Framelabel180" style="Z-INDEX: 256; LEFT: 28px; POSITION: absolute; TOP: 3276px; width: 225px; right: 619px;"
				runat="server" Height="56px" Text="Data wypełnienia zgłoszenia" Number="122" 
                ValueStyle="Date"></ea:framelabel>
<ea:framelabel id="Framelabel137" style="Z-INDEX: 257; LEFT: 252px; POSITION: absolute; TOP: 3276px; width: 378px; right: 485px;"
				runat="server" Height="56px" 
                Text="Podpis (i pieczątka) składającego / osoby reprezentującej składającego &lt;.Normal&gt;(niepotrzebne skreślić)&lt;./&gt;" 
                Number="123"></ea:framelabel>
<ea:framelabel id="FrameLabel127" style="Z-INDEX: 258; LEFT: 0px; POSITION: absolute; TOP: 3339px; height: 170px;"
				runat="server" Width="630px" Text="G. ADNOTACJE URZĘDU SKARBOWEGO" 
                FrameStyle="BigYellowBold"></ea:framelabel>
<ea:framelabel id="FrameLabel130" style="Z-INDEX: 259; LEFT: 28px; POSITION: absolute; TOP: 3360px; height: 87px;"
				runat="server" Width="602px" Text="Uwagi urzędu skarbowego" 
                FrameStyle="SmallBoldGray" Number="124"></ea:framelabel>
<ea:framelabel id="FrameLabel128" style="Z-INDEX: 260; LEFT: 28px; POSITION: absolute; TOP: 3444px; right: 511px; height: 26px;"
				runat="server" Width="301px" 
                Text="Identyfikator przyjmującego formularz" FrameStyle="SmallBoldGray" 
                Number="125"></ea:framelabel>
<ea:framelabel id="FrameLabel129" style="Z-INDEX: 261; LEFT: 329px; POSITION: absolute; TOP: 3444px; height: 31px;"
				runat="server" Width="301px" Text="Podpis przyjmującego formularz" 
                FrameStyle="SmallBoldGray" Number="126"></ea:framelabel>
<ea:framelabel id="FrameLabel171" style="Z-INDEX: 262; LEFT: 28px; POSITION: absolute; TOP: 3472px; right: 602px; width: 223px; height: 36px;"
				runat="server" Text="Data rejestracji w systemie" 
                FrameStyle="SmallBoldGray" Number="127" ValueStyle="Date"></ea:framelabel>
<ea:framelabel id="FrameLabel172" style="Z-INDEX: 263; LEFT: 252px; POSITION: absolute; TOP: 3472px; right: 420px; width: 169px; height: 36px;"
				runat="server" Text="Identyfikator rejestrującego formularz w systemie" 
                FrameStyle="SmallBoldGray" Number="128"></ea:framelabel>
<ea:framelabel id="FrameLabel173" style="Z-INDEX: 264; LEFT: 420px; POSITION: absolute; TOP: 3472px; right: 590px; width: 210px; height: 36px;"
				runat="server" Text="Podpis rejestrującego formularz w systemie" 
                FrameStyle="SmallBoldGray" Number="129"></ea:framelabel>
<ea:framelabel id="FrameLabel136" style="Z-INDEX: 254; LEFT: 0px; POSITION: absolute; TOP: 3513px; height: 18px;"
				runat="server" Width="630px" 
                Text="Pouczenie&lt;/br&gt; Za wykroczenia skarbowe dotyczące obowiązków ewidencyjnych, o których mowa w art.81 Kodeksu karnego skarbowego, grozi kara grzywny." 
                FrameBorderStyle="None" HorizontalAlign="Center"></ea:framelabel>
<ea:deklaracjafooter id="footer4" 
                style="Z-INDEX: 255; LEFT: 0px; POSITION: absolute; TOP: 3681px" runat="server"
				TitleWidth="106" Symbol="NIP-7" PageNumber="4" PageTotal="4" Version="3"></ea:deklaracjafooter>
<ea:datacontext id="dc" style="Z-INDEX: 256; LEFT: 189px; POSITION: absolute; TOP: 3728px" runat="server"
				TypeName="Soneta.Kadry.PracHistoria,Soneta.KadryPlace" oncontextload="OnContextLoad" 
                LeftMargin="15" PageHeight="977px" PageZoom="108%"></ea:datacontext>
</form>
	</body>
</HTML>

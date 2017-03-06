<%@ Register TagPrefix="ea" Namespace="Soneta.Web" Assembly="Soneta.Web" %>
<%@ Page language="c#" AutoEventWireup="false" codePage="65001" %>
<%@ import Namespace="Soneta.Deklaracje" %>
<%@ import Namespace="Soneta.Deklaracje.PIT" %>
<%@ Import Namespace="Soneta.Core" %>
<%@ import Namespace="Soneta.Business" %>
<%@ import Namespace="Soneta.Types" %>
<%@ import Namespace="Soneta.Tools" %>
<%@ import Namespace="System.Xml" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" >
<HTML>
	<HEAD>
		<title>PIT-11 (23)</title>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		<meta content="Microsoft Visual Studio 7.0" name="GENERATOR">
		<meta content="C#" name="CODE_LANGUAGE">
		<meta content="JavaScript" name="vs_defaultClientScript">
		<meta content="http://schemas.microsoft.com/intellisense/ie5" name="vs_targetSchema">
		<script runat="server">
            public class SrParams : SerializableContextBase {
                public SrParams(Context context) : base(context) {
                }

                bool strony = true;
                [Caption("4 strony")]
                public bool Strony {
                    get { return strony; }
                    set {
                        strony = value;
                        OnChanged(EventArgs.Empty);
                    }
                }
            }

            SrParams srpars;
            [SettingsContext]
            public SrParams SrPars {
                get { return srpars; }
                set { srpars = value; }
            }

            public class Params : ContextBase {
                public Params(Context context) : base(context) {
                }

                bool ord = false;
                [Caption("Drukować ORD-ZU")]
                public bool Ord {
                    get { return ord; }
                    set {
                        ord = value;
                        OnChanged(EventArgs.Empty);
                    }
                }

                bool upo = false;
                [Caption("Drukować UPO")]
                public bool Upo {
                    get { return upo; }
                    set {
                        upo = value;
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

            void OnContextLoad(object sender, EventArgs e) {
                PIT pit = (PIT)dc[typeof(PIT)];
                if (pit as PIT11_23 == null)
                    throw new InvalidOperationException("Wydruk PIT-11 (23) może być drukowany wyłącznie dla deklaracji PIT-11 w wersji 23.");
                PIT11_23 pit11 = (PIT11_23)pit;
                if (!pit.Module.Config.PIT.Ogólne.DanePodatnikaWStopce)
                    flDanePodatnika1.Text = flDanePodatnika2.Text = "";
                else {
                    flDanePodatnika1.Text = flDanePodatnika2.Text = string.Format("{0}, {1}: {2}",
                        pit11.Podmiot.ToString(),
                        pit11.JestPESEL ? "PESEL" : "NIP",
                        pit11.IdentyfikatorPodatnika);
                }
                if (pit11.JestPESEL) {
                    flPeselNip.Text = "<strike>Identyfikator podatkowy NIP</strike>/Numer PESEL <.Indexup>(niepotrzebne skreślić)";
                    flPeselNip.ValueStyle = ValueStyles.WideText;
                }
                else {
                    flPeselNip.Text = "Identyfikator podatkowy NIP/<strike>Numer PESEL</strike> <.Indexup>(niepotrzebne skreślić)";
                    flPeselNip.ValueStyle = ValueStyles.nip_w;
                }
                Strony.Visible = srpars.Strony;

                string rodzaj = (string)pit11.Bloki["C1"]["RodzajDok"];
                if (rodzaj.Contains("/")) rodzaj = rodzaj.Substring(0, rodzaj.IndexOf("/"));
                Framelabel12.EditValue = rodzaj;

                if (pars.Ord) {
                    Soneta.Deklaracje.PIT.ITreśćUzasadnieniaKorekty dek = (Soneta.Deklaracje.PIT.ITreśćUzasadnieniaKorekty)dc[typeof(Soneta.Deklaracje.PIT.ITreśćUzasadnieniaKorekty)];
                    if (dek.Visible)
                        dc.FollowingReports.Add(new FollowingReport("deklaracje/ord_zu_2.aspx"));
                }

                if (!dc.OverPrint) {
                    if (pars.Upo) {
                        string upo = pit.GetNumerUpo();
                        if (upo == "") {
                            DefinicjaDokumentu dd = CoreModule.GetInstance(dc).DefDokumentow.WgSymbolu["PIT11Z"];
                            SubTable st = DeklaracjeModule.GetInstance(dc).Deklaracje.WgDefinicja[dd];
                            st = st[new RowCondition.Exists("Deklaracje", "Deklaracja", new FieldCondition.Equal("Guid", pit.Guid))];
                            if (!st.IsEmpty) {
                                Deklaracja dek = (Deklaracja)st.GetPrev();
                                Soneta.Business.View v = dek.EDeklaracje.CreateView();
                                EDeklaracja edek = (EDeklaracja)v.GetLast();
                                if (edek != null && !string.IsNullOrEmpty(edek.GetUPO())) {
                                    XmlDocument document = new XmlDocument();
                                    document.LoadXml(edek.GetUPO());
                                    XmlNamespaceManager nm = new XmlNamespaceManager(document.NameTable);
                                    XmlNode nodeToFind = document.SelectSingleNode("//Potwierdzenie/NumerReferencyjny", nm);
                                    if (nodeToFind != null) {
                                        XmlNode node = document.SelectSingleNode("//Potwierdzenie/NumerReferencyjny/text()", nm);
                                        upo = node.Value;
                                    }
                                }
                            }
                        }
                        if (upo != "") {
                            Resize(FrameNIPPlatnika, -64, 0);
                            Move(FrameNrDokumentu, 0, -64);
                            Resize(FrameNrDokumentu, 64, 0);
                            FrameNrDokumentu.EditValue = upo;
                        }
                    }
                }
                else {
                    dc.LeftMargin = 6;
                    dc.TopMargin = 6;
                    dc.PageZoom = "114%";

                    // 1. Identyfikator podatkowy NIP płatnika
                    Move(FrameNIPPlatnika, -2, -9);
                    // 4. Rok
                    FrameLabel24.Visible=false;
                    FrameLabel25.Visible=false;
                    FrameLabel26.Visible=false;
                    FrameLabel27.Visible=false;
                    FrameLabel28.Visible=false;
                    FrameLabel30.Visible=false;
                    FrameLabel31.Visible=false;
                    FrameLabel32.Visible=false;
                    FrameLabel33.Visible=false;
                    FrameLabel19.Visible=false;
                    //Move(FrameLabel19, 16, 9);
                    // 5. Urząd skarbowy, do którego adresowana jest informacja
                    FrameLabel17.Visible=false;
                    Move(FrameLabel18, 53, 0);
                    Framelabel77.Visible=false;			// pole 6
                    // 1. złożenie informacji
                    FrameLabel1.Visible=false;
                    FrameLabel3.Visible=false;
                    Move(Checklabel10, 50, -10);
                    // 2. korekta informacji
                    Move(Checklabel9, 50,  -10);
                    // 7. 1. płatnik niebędący osobą fizyczną
                    Move(CheckLabel1, 51, -5);
                    // 7. 2. osoba fizyczna
                    Move(CheckLabel2, 51, -5);
                    // 8. Nazwa pełna, REGON
                    Move(FrameLabel20, 60, 0);
                    // 9. Nazwisko, pierwsze imię, data urodzenia
                    Move(FrameLabel4, 65, 0);
                    // 10. Rodzaj obowiązku podatkowego podatnika
                    Framelabel41.Visible=false;
                    FrameLabel9.Visible=false;
                    // 1. rezydent
                    Move(CheckLabel7, 65, 5);
                    // 2. nierezydent
                    Move(CheckLabel8, 65, 20);
                    // 11. Identyfikator podatkowy NIP/Numer PESEL
                    Move(flPeselNip, 64, -230);
                    // 12. Zagraniczny numer identyfikacyjny podatnika
                    Move(Framelabel11, 70, 0);
                    // 13. Rodzaj numeru identyfikacyjnego
                    Move(Framelabel12, 70, 0);
                    // 14. Kraj wydania numeru identyfikacyjnego
                    Move(Framelabel15, 70, 0);
                    // 15. Nazwisko
                    Move(Framelabel103, 70, 0);
                    // 16. Pierwsze imię
                    Move(Framelabel104, 70, 0);
                    // 17. Data urodzenia
                    Move(Framelabel105, 70, 0);
                    // 18. Kraj
                    Move(Framelabel106, 70, 0);
                    // 19. Województwo
                    Move(Framelabel107, 70, 0);
                    // 20. Powiat
                    Move(Framelabel108, 70, 0);
                    // 21. Gmina
                    Move(Framelabel109, 70, 0);
                    // 22. Ulica
                    Move(Framelabel110, 70, 0);
                    // 23. Nr domu
                    Move(Framelabel111, 70, 0);
                    // 24. Nr lokalu
                    Move(Framelabel112, 70, 0);
                    // 25. Miejscowość
                    Move(Framelabel113, 70, 0);
                    // 26. Kod pocztowy
                    Move(Framelabel114, 70, 0);
                    // 27. Poczta
                    Move(Framelabel115, 70, 0);
                    // 28. Koszty uzyskania przychodów, wykazane w poz. 30
                    Framelabel116.Visible=false;
                    Framelabel117.Visible=false;
                    //Move(Framelabel117, 50, 0);
                    // 1. z jednego stosunku pracy (stosunków pokrewnych)
                    Move(Checklabel3, 71, -10);
                    // 2. z więcej niż jednego stosunku pracy (stosunków pokrewnych)
                    Move(Checklabel4, 71, -10);
                    // 3. z jednego stosunku pracy (stosunków pokrewnych), podwyższone w związku z zamieszkiwaniem podatnika poza 
                    Move(Checklabel5, 71, -10);
                    // 4. z więcej niż jednego stosunku pracy (stosunków pokrewnych), podwyższone w związku z zamieszkiwaniem podatnika 
                    Move(Checklabel6, 71, -10);
                    // 29
                    Resize(Framelabel49, -5, 0);
                    Move(Framelabel49, -25, -28);
                    // 30
                    Move(Framelabel51, -25, -28);
                    // 31
                    Move(Framelabel53, -25, -21);
                    // 32
                    Resize(Framelabel154, -5, 0);
                    Move(Framelabel154, -25, -8);
                    // 33
                    Resize(Framelabel54, -5, 0);
                    Move(Framelabel54, -25, 0);
                    // 34
                    Resize(Framelabel50, -5, -0);
                    Move(Framelabel50, -25, -28);
                    // 35
                    Move(Framelabel52, -25, -28);
                    // 36
                    Resize(Framelabel57, -5, -15);
                    Move(Framelabel57, -15, -28);
                    // 37
                    Resize(Framelabel59, -0, -15);
                    Move(Framelabel59, -15, -21);
                    // 38
                    Resize(Framelabel60, -5, -15);
                    Move(Framelabel60, -15, 7);
                    // 39
                    Move(Framelabel62, -30, -35);
                    // 40
                    Move(Framelabel64, -30, -19);
                    // 41
                    Move(Framelabel156, -30, -12);
                    // 42
                    Move(Framelabel65, -30, 0);
                    // 43
                    Move(Framelabel72, -30, -35);
                    // 44
                    Move(Framelabel85, -30, -19);
                    // 45
                    Move(Framelabel91, -30, 0);
                    // 46
                    Move(Framelabel73, -30, -35);
                    // 47
                    Move(Framelabel86, -30, -19);
                    // 48
                    Move(Framelabel92, -30, 0);
                    // 49
                    Move(Framelabel74, -30, -35);
                    Resize(Framelabel74, 0, -15);
                    // 50
                    Move(Framelabel100, -30, -28);
                    Resize(Framelabel100, 0, -15);
                    // 51
                    Move(Framelabel87, -30, -19);
                    Resize(Framelabel87, 0, -15);
                    // 52
                    Move(Framelabel93, -30, 0);
                    Resize(Framelabel93, 0, -15);
                    // 53
                    Move(Framelabel98, -30, -35);
                    // 54
                    Move(Framelabel80, -30, -28);
                    // 55
                    Move(Framelabel118, -30, -19);
                    // 56
                    Move(Framelabel120, -30, 0);
                    // 57
                    Move(Framelabel135, -30, -35);
                    // 58
                    Move(Framelabel141, -30, -19);
                    // 59
                    Move(Framelabel143, -30, 0);
                    // 60
                    Move(Framelabel2, -30, -35);
                    // 61
                    Move(Framelabel5, -30, -28);
                    // 62
                    Move(Framelabel90, -30, -35);
                    // 63
                    Move(Framelabel96, -30, -28);
                    // 64
                    Move(Framelabel145, -30, -19);
                    // 65
                    Move(Framelabel146, -30, 0);
                    // 66
                    Move(Framelabel76, -30, -35);
                    // 67
                    Move(Framelabel89, -30, -19);
                    // 68
                    Move(Framelabel157, -30, -12);
                    // 69
                    Move(Framelabel95, -30, 0);
                    // 70
                    Move(Framelabel99, -30, 9);
                    // 71
                    Move(Framelabel148, -30, 9);
                    // 72
                    Move(Framelabel119, -30, 9);
                    // 73
                    Move(Framelabel150, -30, 9);
                    // 74
                    Move(Framelabel78, -27, 9);
                    // 75
                    Move(Framelabel83, -27, 9);
                    // 76. Do niniejszej informacji dołączono informację PIT-R
                    // 1
                    FrameLabel79.Visible=false;
                    Move(Checklabel_82_T, -25, -3);
                    // 2
                    Move(Checklabel_82_N, -27, -5);
                    // 77 Imię
                    Move(flGImie, -30, -19);
                    // 78 Nazwisko
                    Move(flGNazwisko, -30, -19);
                }
            }

            void Resize(WebControl fl, int dwidth, int dheight) {
                if (dwidth != 0)
                    fl.Style["width"] = (ParsePx(fl.Style["width"]) + dwidth) + "px";
                if (dheight != 0)
                    fl.Style["height"] = (ParsePx(fl.Style["height"]) + dheight) + "px";
            }

            void Move(WebControl fl, int dtop, int dleft) {
                if (dtop != 0)
                    fl.Style["TOP"] = (ParsePx(fl.Style["TOP"]) + dtop) + "px";
                if (dleft != 0)
                    fl.Style["LEFT"] = (ParsePx(fl.Style["LEFT"]) + dleft) + "px";
            }

            int ParsePx(string px) {
                return int.Parse(px.Substring(0, px.Length - 2));
            }

            protected void Page_Load(object sender, EventArgs e)
            {

            }
</script>
	</HEAD>
	<body leftMargin="0" rightMargin="0">
		<form id="PIT_11_23" method="post" runat="server">
			<ea:deklaracjaheader id="DeklaracjaHeader1" style="Z-INDEX: 100; LEFT: 0px; POSITION: absolute; TOP: 0px"
				runat="server" Width="630px" StylNagłówka="JasneCiemneElektroniczniePortal"></ea:deklaracjaheader>
<ea:framelabel id="FrameNIPPlatnika" style="Z-INDEX: 101; LEFT: 0px; POSITION: absolute; TOP: 21px; width: 338px;"
				runat="server" ValueStyle="nip_w" DataMember="0.Nip" Height="28px" 
                Text="1. Identyfikator podatkowy NIP płatnika"></ea:framelabel>
<ea:framelabel id="FrameNrDokumentu" style="Z-INDEX: 102; LEFT: 337px; POSITION: absolute; TOP: 21px; width: 193px;"
				runat="server" Height="28px" Text="Nr dokumentu" FrameStyle="SmallBoldGray" Number="2"></ea:framelabel>
<ea:framelabel id="FrameLabel23" style="Z-INDEX: 103; LEFT: 531px; POSITION: absolute; TOP: 21px; width: 97px;"
				runat="server" Height="30px" Text="Status" FrameStyle="SmallBoldGray" Number="3"></ea:framelabel>
<ea:framelabel id="labelPIT" style="Z-INDEX: 104; LEFT: 0px; POSITION: absolute; TOP: 49px" runat="server"
				Width="119px" Height="21px" FrameStyle="BigBold" FrameBorderStyle="None" Text="PIT-11"></ea:framelabel>
<ea:framelabel id="FrameLabel158" style="Z-INDEX: 105; LEFT: 126px; POSITION: absolute; TOP: 63px"
				runat="server" Width="525px" Height="35px" 
                Text="INFORMACJA O  DOCHODACH ORAZ O POBRANYCH ZALICZKACH<br>NA PODATEK DOCHODOWY" 
                FrameStyle="BigBold" FrameBorderStyle="None" HorizontalAlign="Center"></ea:framelabel>
<ea:framelabel id="FrameLabel19" style="Z-INDEX: 106; LEFT: 259px; POSITION: absolute; TOP: 105px; width: 115px;"
				runat="server" ValueStyle="n4" DataMember="0.Rok" Height="28px" Text="4. Rok"></ea:framelabel>
<ea:framelabel id="FrameLabel29" style="Z-INDEX: 108; LEFT: 170px; POSITION: absolute; TOP: 112px"
				runat="server" Width="70px" Height="17px" Text="W ROKU" FrameStyle="BigBold" 
                FrameBorderStyle="None"></ea:framelabel>
<ea:framelabel id="FrameLabel24" style="Z-INDEX: 109; LEFT: 0px; POSITION: absolute; TOP: 135px"
				runat="server" Width="630px" Height="112px" FrameStyle="SmallBoldYellow"></ea:framelabel>
<ea:framelabel id="FrameLabel25" style="Z-INDEX: 110; LEFT: 7px; POSITION: absolute; TOP: 137px"
				runat="server" Width="91px" Height="7px" Text="Podstawa prawna:" FrameStyle="SmallYellow" FrameBorderStyle="None"></ea:framelabel>
<ea:framelabel id="FrameLabel26" style="Z-INDEX: 111; LEFT: 100px; POSITION: absolute; TOP: 137px"
				runat="server" Width="523px" Height="28px" Text='Art. 39 ust. 1, art. 42 ust. 2 pkt 1 i art. 42e ust. 6 ustawy z dnia 26 lipca 1991 r. o podatku dochodowym od osób fizycznych (Dz. U. z 2012 r. poz. 361, z późn. zm.), zwanej dalej "ustawą"; art. 35a ust. 5 ustawy, w brzmieniu obowiązującym przed dniem 26 października 2007 r. <.INDEXUP>1)<./>. ' FrameStyle="SmallYellow"
				FrameBorderStyle="None"></ea:framelabel>
<ea:framelabel id="FrameLabel27" style="Z-INDEX: 112; LEFT: 7px; POSITION: absolute; TOP: 157px"
				runat="server" Width="91px" Height="7px" Text="Składający:" FrameStyle="SmallYellow" 
                FrameBorderStyle="None"></ea:framelabel>
<ea:framelabel id="FrameLabel28" style="Z-INDEX: 113; LEFT: 100px; POSITION: absolute; TOP: 157px"
				runat="server" Width="523px" Height="7px" 
                Text="Płatnik podatku dochodowego od osób fizycznych." FrameStyle="SmallYellow" 
                FrameBorderStyle="None"></ea:framelabel>
<ea:framelabel id="FrameLabel30" style="Z-INDEX: 114; LEFT: 7px; POSITION: absolute; TOP: 166px"
				runat="server" Width="91px" Height="7px" Text="Termin składania:" 
                FrameStyle="SmallYellow" FrameBorderStyle="None"></ea:framelabel>
<ea:framelabel id="FrameLabel31" style="Z-INDEX: 115; LEFT: 100px; POSITION: absolute; TOP: 166px"
				runat="server" Width="523px" Height="56px" Text="Do końca lutego roku następującego po roku podatkowym - wyłącznie dla informacji składanych urzędowi skarbowemu za pomocą środków komunikacji elektronicznej lub podatnikowi; do końca stycznia roku następującego po roku podatkowym w przypadku informacji składanych urzędowi skarbowemu w formie pisemnej, zgodnie z art. 45ba ust. 2 ustawy.<br/>W przypadku gdy, w trakcie roku podatkowego ustał obowiązek poboru zaliczki przez płatników, o których mowa w art. 39 ust. 1 ustawy - w terminie 14 dni od złożenia pisemnego wniosku przez podatnika, w przypadku zaprzestania działalności przez płatników, o których mowa w art. 41 ust. 1 ustawy, przed końcem lutego roku następującego po roku podatkowym - do dnia zaprzestania tej działalności."
				FrameStyle="SmallYellow" FrameBorderStyle="None"></ea:framelabel>
<ea:framelabel id="FrameLabel32" style="Z-INDEX: 116; LEFT: 7px; POSITION: absolute; TOP: 224px"
				runat="server" Width="91px" Height="7px" Text="Otrzymuje:" FrameStyle="SmallYellow" FrameBorderStyle="None"></ea:framelabel>
<ea:framelabel id="FrameLabel33" style="Z-INDEX: 117; LEFT: 100px; POSITION: absolute; TOP: 224px"
				runat="server" Width="523px" Height="21px" Text="Podatnik oraz urząd skarbowy według miejsca zamieszkania podatnika, a w przypadku podatników, o których mowa w art. 3 ust. 2a ustawy, urząd skarbowy w sprawach opodatkowania osób zagranicznych."
				FrameStyle="SmallYellow" FrameBorderStyle="None"></ea:framelabel>
<ea:framelabel id="FrameLabel17" style="Z-INDEX: 118; LEFT: 0px; POSITION: absolute; TOP: 245px"
				runat="server" Width="630px" Height="84px" Text="A. MIEJSCE I CEL SKŁADANIA INFORMACJI" FrameStyle="BigYellowBold" FrameBorderStyle="DoubleHeader"></ea:framelabel>
<ea:framelabel id="FrameLabel18" style="Z-INDEX: 119; LEFT: 28px; POSITION: absolute; TOP: 273px"
				runat="server" Width="602px" DataMember="A.UrzadSkarb" Height="28px" Text="Urząd skarbowy, do którego adresowana jest informacja<.INDEXUP>2)<./>" Number="5"></ea:framelabel>
<ea:framelabel id="Framelabel77" style="Z-INDEX: 120; LEFT: 28px; POSITION: absolute; TOP: 301px"
				runat="server" Width="602px" Height="28px" Text="Cel złożenia formularza <.Normal>(zaznaczyć właściwy kwadrat):<./>" Number="6">
                </ea:FrameLabel>
<ea:checklabel id="Checklabel10" style="Z-INDEX: 121; LEFT: 219px; POSITION: absolute; TOP: 308px"
				runat="server" Width="136px" DataMember="A.Korekta" Height="14px" Text="złożenie informacji" Number="1" NumberAlignLeft="False" ComparedValue="False">
            </ea:CheckLabel>
<ea:checklabel id="Checklabel9" style="Z-INDEX: 122; LEFT: 358px; POSITION: absolute; TOP: 308px"
				runat="server" Width="133px" DataMember="A.Korekta" Height="14px" Text="korekta informacji 3)" Number="2" NumberAlignLeft="False"></ea:checklabel>
<ea:framelabel id="FrameLabel1" style="Z-INDEX: 123; LEFT: 0px; POSITION: absolute; TOP: 329px"
				runat="server" Width="630px" Height="122px" Text="B. DANE IDENTYFIKACYJNE PŁATNIKA&lt;br&gt;&lt;.Footer&gt;* - dotyczy płatnika niebędącego osobą fizyczną ** - dotyczy płatnika będącego osobą fizyczną&lt;./&gt;" FrameStyle="BigYellowBold" FrameBorderStyle="DoubleHeader"></ea:framelabel>
<ea:framelabel id="FrameLabel3" style="Z-INDEX: 124; LEFT: 28px; POSITION: absolute; TOP: 364px"
				runat="server" Width="602px" Height="28px" Text="Rodzaj płatnika <.Normal>(zaznaczyć właściwy kwadrat):<./>" Number="7"></ea:framelabel>
<ea:checklabel id="CheckLabel1" style="Z-INDEX: 125; LEFT: 132px; POSITION: absolute; TOP: 371px"
				runat="server" Width="161px" DataMember="B1.OsobaFiz" Height="14px" Text="płatnik niebędący osobą fizyczną" Number="1" NumberAlignLeft="False" ComparedValue="False">
            </ea:CheckLabel>
<ea:checklabel id="CheckLabel2" style="Z-INDEX: 126; LEFT: 423px; POSITION: absolute; TOP: 371px"
				runat="server" Width="133px" DataMember="B1.OsobaFiz" Height="14px" Text="osoba fizyczna" Number="2" NumberAlignLeft="False">
            </ea:CheckLabel>
<ea:framelabel id="FrameLabel20" style="Z-INDEX: 128; LEFT: 29px; POSITION: absolute; TOP: 392px; height: 25px;"
				runat="server" Width="602px" DataMember="NazwaFirma" 
                Text="Nazwa pełna, REGON *" 
                SmallerFontLength="70" 
                Number="8"></ea:framelabel>
<ea:framelabel id="FrameLabel4" style="Z-INDEX: 129; LEFT: 28px; POSITION: absolute; TOP: 420px; height: 25px;"
				runat="server" Width="602px" DataMember="NazwaOsobaFizycza" 
                Text="Nazwisko, pierwsze imię, data urodzenia **" 
                SmallerFontLength="70"
                Number="9"></ea:framelabel>
<ea:framelabel id="Framelabel41" style="Z-INDEX: 140; LEFT: 0px; POSITION: absolute; TOP: 447px"
				runat="server" Width="630px" Height="250px" Text="C. DANE IDENTYFIKACYJNE I ADRES ZAMIESZKANIA PODATNIKA" FrameStyle="BigYellowBold" FrameBorderStyle="DoubleHeader"></ea:framelabel>
<ea:framelabel id="FrameLabel9" style="Z-INDEX: 141; LEFT: 28px; POSITION: absolute; TOP: 476px"
				runat="server" Width="602px" Height="28px" Text="Rodzaj obowiązku podatkowego podatnika <.Normal>(zaznaczyć właściwy kwadrat)<./>" Number="10"></ea:framelabel>
<ea:checklabel id="CheckLabel7" style="Z-INDEX: 141; LEFT: 74px; POSITION: absolute; TOP: 485px" DataMember="C1.Rezydent"
				runat="server" Width="280px" Height="14px" Text="nieograniczony obowiązek podatkowy (rezydent)" Number="1" NumberAlignLeft="False">
            </ea:CheckLabel>
<ea:checklabel id="CheckLabel8" style="Z-INDEX: 141; LEFT: 355px; POSITION: absolute; TOP: 485px" DataMember="C1.Rezydent"
				runat="server" Width="280px" Height="14px" Text="ograniczony obowiązek podatkowy (nierezydent) 4)" Number="2" NumberAlignLeft="False" ComparedValue="False">
            </ea:CheckLabel>
<ea:framelabel id="flPeselNip" style="Z-INDEX: 142; LEFT: 28px; POSITION: absolute; TOP: 504px; width: 601px;"
				runat="server" DataMember="IdentyfikatorPodatnika" Height="28px" 
                Text="Identyfikator podatkowy NIP/Numer PESEL &lt;.Indexup&gt;(niepotrzebne skreślić) &lt;/Indexup&gt;" 
                Number="11"></ea:framelabel>
<ea:framelabel id="Framelabel11" style="Z-INDEX: 142; LEFT: 28px; POSITION: absolute; TOP: 532px; width: 601px;"
				runat="server" DataMember="C1.ZagrNIP"
                Text="Zagraniczny numer identyfikacyjny podatnika <.Normal> &lt;.Indexup&gt;5)" 
                Height="28px" Number="12"></ea:framelabel>
<ea:framelabel id="Framelabel12" style="Z-INDEX: 142; LEFT: 28px; POSITION: absolute; TOP: 560px; width: 300px;"
				runat="server"
                Text="&lt;.Indexup&gt;Rodzaj numeru identyfikacyjnego (dokumentu stwierdzającego tożsamość) 6)" 
                Height="28px" Number="13"></ea:framelabel>
<ea:framelabel id="Framelabel15" style="Z-INDEX: 142; LEFT: 329px; POSITION: absolute; TOP: 560px; width: 300px;"
				runat="server" DataMember="C1.KrajDok"
                Text="&lt;.Indexup&gt;Kraj wydania numeru identyfikacyjnego (dokumentu stwierdzającego tożsamość) 6)" 
                Height="28px" Number="14"></ea:framelabel>
<ea:framelabel id="Framelabel103" 
                style="Z-INDEX: 143; LEFT: 28px; POSITION: absolute; TOP: 588px; width: 240px; right: 557px;" SmallerFontLength="30"
				runat="server" DataMember="C1.Nazwisko" Height="28px" Text="Nazwisko" Number="15"></ea:framelabel>
<ea:framelabel id="Framelabel104" style="Z-INDEX: 144; LEFT: 266px; POSITION: absolute; TOP: 588px; width: 189px;"
				runat="server" DataMember="C1.Imię" Height="28px" Text="Pierwsze imię" Number="16"></ea:framelabel>
<ea:framelabel id="Framelabel105" style="Z-INDEX: 145; LEFT: 455px; POSITION: absolute; TOP: 588px; width: 172px;"
				runat="server" ValueStyle="Date" DataMember="C1.DataUrodz" Height="28px" 
                Text="Data urodzenia" Number="17"></ea:framelabel>
<ea:framelabel id="Framelabel106" style="Z-INDEX: 147; LEFT: 28px; POSITION: absolute; TOP: 615px"
				runat="server" Width="140px" DataMember="C2.Kraj" Height="28px" Text="Kraj" Number="18"></ea:framelabel>
<ea:framelabel id="Framelabel107" style="Z-INDEX: 148; LEFT: 168px; POSITION: absolute; TOP: 615px"
				runat="server" Width="266px" DataMember="C2.Wojew" Height="28px" Text="Województwo" Number="19"></ea:framelabel>
<ea:framelabel id="Framelabel108" style="Z-INDEX: 149; LEFT: 434px; POSITION: absolute; TOP: 615px"
				runat="server" Width="196px" DataMember="C2.Powiat" Height="28px" Text="Powiat" Number="20"></ea:framelabel>
<ea:framelabel id="Framelabel109" style="Z-INDEX: 150; LEFT: 28px; POSITION: absolute; TOP: 643px" SmallerFontLength="16"
				runat="server" Width="161px" DataMember="C2.Gmina" Height="28px" Text="Gmina" Number="21"></ea:framelabel>
<ea:framelabel id="Framelabel110" style="Z-INDEX: 151; LEFT: 189px; POSITION: absolute; TOP: 643px"
				runat="server" Width="301px" DataMember="C2.Ulica" Height="28px" Text="Ulica" SmallerFontLength="35"
                Number="22"></ea:framelabel>
<ea:framelabel id="Framelabel111" style="Z-INDEX: 152; LEFT: 490px; POSITION: absolute; TOP: 643px" SmallerFontLength="6"
				runat="server" Width="70px" DataMember="C2.NrDomu" Height="28px" Text="Nr domu" Number="23"></ea:framelabel>
<ea:framelabel id="Framelabel112" style="Z-INDEX: 153; LEFT: 560px; POSITION: absolute; TOP: 643px"
				runat="server" Width="70px" DataMember="C2.NrLokalu" Height="28px" Text="Nr lokalu" Number="24"></ea:framelabel>
<ea:framelabel id="Framelabel113" style="Z-INDEX: 154; LEFT: 28px; POSITION: absolute; TOP: 671px" SmallerFontLength="30"
				runat="server" Width="252px" DataMember="C2.Miejsc" Height="28px" Text="Miejscowość" Number="25"></ea:framelabel>
<ea:framelabel id="Framelabel114" style="Z-INDEX: 155; LEFT: 280px; POSITION: absolute; TOP: 671px"
				runat="server" Width="105px" ValueStyle="PostalCode" DataMember="C2.KodPoczt" Height="28px" Text="Kod pocztowy" Number="26"></ea:framelabel>
<ea:framelabel id="Framelabel115" style="Z-INDEX: 156; LEFT: 385px; POSITION: absolute; TOP: 671px"
				runat="server" Width="245px" DataMember="C2.Poczta" Height="28px" Text="Poczta" Number="27"></ea:framelabel>
<ea:framelabel id="Framelabel116" style="Z-INDEX: 157; LEFT: 0px; POSITION: absolute; TOP: 699px"
				runat="server" Width="630px" Height="107px" 
                Text="D. INFORMACJA O KOSZTACH UZYSKANIA PRZYCHODU &lt;.SMALLER&gt;Z TYTUŁU STOSUNKU SŁUŻBOWEGO,&lt;br&gt;STOSUNKU PRACY, SPÓŁDZIELCZEGO STOSUNKU PRACY ORAZ PRACY NAKŁADCZEJ&lt;./&gt;" 
                FrameStyle="BigYellowBold" FrameBorderStyle="DoubleHeader"></ea:framelabel>
<ea:framelabel id="Framelabel117" style="Z-INDEX: 158; LEFT: 28px; POSITION: absolute; TOP: 734px"
				runat="server" Width="602px" Height="71px" Text="Koszty uzyskania przychodów, wykazane w poz. 30, zostały uwzględnione do wysokości przysługującej podatnikowi <.Normal>(zaznaczyć właściwy kwadrat):<./>" Number="28"></ea:framelabel>
<ea:checklabel id="Checklabel3" style="Z-INDEX: 159; LEFT: 44px; POSITION: absolute; TOP: 752px"
				runat="server" Width="287px" DataMember="D.Jeden" Height="14px" Text="z jednego stosunku pracy (stosunków pokrewnych)" Number="1" NumberAlignLeft="False" AlignTop="True"></ea:checklabel>
<ea:checklabel id="Checklabel4" style="Z-INDEX: 160; LEFT: 335px; POSITION: absolute; TOP: 752px"
				runat="server" Width="280px" DataMember="D.Wiecej" Height="12px" Text="z więcej niż jednego stosunku pracy (stosunków pokrewnych)" Number="2" NumberAlignLeft="False" AlignTop="True"></ea:checklabel>
<ea:checklabel id="Checklabel5" style="Z-INDEX: 161; LEFT: 44px; POSITION: absolute; TOP: 769px"
				runat="server" Width="286px" DataMember="D.JedenPodw" Height="14px" Text="z jednego stosunku pracy (stosunków pokrewnych), podwyższone w związku z zamieszkiwaniem podatnika poza miejscowością, w której znajduje się zakład pracy" Number="3" NumberAlignLeft="False" AlignTop="True"></ea:checklabel>
<ea:checklabel id="Checklabel6" style="Z-INDEX: 162; LEFT: 335px; POSITION: absolute; TOP: 769px"
				runat="server" Width="277px" DataMember="D.WiecejPodw" Height="14px" Text="z więcej niż jednego stosunku pracy (stosunków pokrewnych), podwyższone w związku z zamieszkiwaniem podatnika poza miejscowością, w której znajduje się zakład pracy" Number="4" NumberAlignLeft="False" AlignTop="True"></ea:checklabel>
<ea:deklaracjafooter id="footer1" 
                style="Z-INDEX: 188; LEFT: 490px; POSITION: absolute; TOP: 930px" runat="server"
				Width="154px" Height="10px" TitleWidth="106" Symbol="PIT-11" PageNumber="1" 
                PageTotal="3" Version="23"></ea:deklaracjafooter>
<ea:deklaracjaheader id="DeklaracjaHeader2" style="Z-INDEX: 189; LEFT: 0px; POSITION: absolute; TOP: 986px"
				runat="server" Width="630px" StylNagłówka="JasneCiemneElektroniczniePortal"></ea:deklaracjaheader>
<ea:framelabel id="FrameLabel16" style="Z-INDEX: 166; LEFT: 0px; POSITION: absolute; TOP: 1010px; height: 585px;"
				runat="server" Width="630px" 
                Text="E. DOCHODY PODATNIKA, POBRANE ZALICZKI ORAZ POBRANE SKŁADKI <.INDEXUP>9)<./>" 
                FrameStyle="BigYellowBold"></ea:framelabel>
<ea:framelabel id="FrameLabel39" style="Z-INDEX: 167; LEFT: 28px; POSITION: absolute; TOP: 1031px; width: 221px;"
				runat="server" Height="36px" Text="Źródła przychodów" FrameStyle="SmallBoldYellow" 
                HorizontalAlign="Center"></ea:framelabel>
<ea:framelabel id="FrameLabel37" style="Z-INDEX: 168; LEFT: 252px; POSITION: absolute; TOP: 1031px; width: 78px; right: 617px;"
				runat="server" ValueStyle="ZlGr" Height="36px" Text="Przychód <.INDEXUP>7)<./>" 
                FrameStyle="SmallBoldYellow" HorizontalAlign="Center"></ea:framelabel>
<ea:framelabel id="FrameLabel40" style="Z-INDEX: 169; LEFT: 329px; POSITION: absolute; TOP: 1031px; width: 79px;"
				runat="server" ValueStyle="ZlGr" Height="36px" 
                Text="Koszty uzyskania<br>przychodów <.INDEXUP>8)<./>" 
                FrameStyle="SmallBoldYellow" HorizontalAlign="Center"></ea:framelabel>
<ea:framelabel id="FrameLabel42" style="Z-INDEX: 170; LEFT: 406px; POSITION: absolute; TOP: 1031px; width: 80px;"
				runat="server" Height="36px" Text="Dochód<br>(b-c)" FrameStyle="SmallBoldYellow" 
                HorizontalAlign="Center" ValueStyle="ZlGr"></ea:framelabel>
<ea:framelabel id="FrameLabel152" style="Z-INDEX: 170; LEFT: 483px; POSITION: absolute; TOP: 1031px; width: 80px;"
				runat="server" Height="36px" 
                Text="Dochód zwolniony &lt;br&gt; od podatku &lt;.INDEXUP&gt;7)&lt;./&gt;" FrameStyle="SmallBoldYellow" 
                HorizontalAlign="Center" ValueStyle="ZlGr"></ea:framelabel>
<ea:framelabel id="FrameLabel43" style="Z-INDEX: 171; LEFT: 560px; POSITION: absolute; TOP: 1031px; width: 69px;"
				runat="server" Height="36px" Text="Zaliczka pobrana<br>przez płatnika" 
                FrameStyle="SmallBoldYellow" HorizontalAlign="Center" ValueStyle="Zl"></ea:framelabel>
<ea:framelabel id="FrameLabel38" style="Z-INDEX: 172; LEFT: 28px; POSITION: absolute; TOP: 1066px; height: 19px; width: 222px;"
				runat="server" Text="a" FrameStyle="SmallBoldYellow" HorizontalAlign="Center"></ea:framelabel>
<ea:framelabel id="FrameLabel44" style="Z-INDEX: 173; LEFT: 252px; POSITION: absolute; TOP: 1066px; width: 79px;"
				runat="server" Height="19px" Text="b" FrameStyle="SmallBoldYellow" 
                HorizontalAlign="Center"></ea:framelabel>
<ea:framelabel id="FrameLabel45" style="Z-INDEX: 174; LEFT: 329px; POSITION: absolute; TOP: 1066px; height: 19px; width: 76px;"
				runat="server" Text="c" FrameStyle="SmallBoldYellow" HorizontalAlign="Center"></ea:framelabel>
<ea:framelabel id="FrameLabel46" style="Z-INDEX: 175; LEFT: 406px; POSITION: absolute; TOP: 1066px; width: 79px;"
				runat="server" Height="19px" Text="d" FrameStyle="SmallBoldYellow" 
                HorizontalAlign="Center"></ea:framelabel>
<ea:framelabel id="FrameLabel153" style="Z-INDEX: 175; LEFT: 483px; POSITION: absolute; TOP: 1066px; width: 79px;"
				runat="server" Height="19px" Text="e" FrameStyle="SmallBoldYellow" 
                HorizontalAlign="Center"></ea:framelabel>
<ea:framelabel id="FrameLabel47" style="Z-INDEX: 176; LEFT: 560px; POSITION: absolute; TOP: 1066px; width: 67px;"
				runat="server" Height="19px" Text="f" FrameStyle="SmallBoldYellow" 
                HorizontalAlign="Center"></ea:framelabel>
<ea:framelabel id="FrameLabel48" style="Z-INDEX: 177; LEFT: 28px; POSITION: absolute; TOP: 1084px; height: 86px; bottom: 568px; width: 224px;"
				runat="server" 
                Text="Należności ze stosunku: pracy, służbowego, spółdzielczego i z pracy nakładczej, a także zasiłki pieniężne z ubezpieczenia społecznego wypłacone przez zakład pracy,o którym mowa w art. 31 ustawy oraz płatników, o których mowa w art. 42e ust. 1 ustawy" FrameStyle="SmallBoldYellow"
				Number="1" HorizontalAlign="Left" 
                FooterText="W poz. 34 należy wykazać przychody, do których zastosowano odliczenie kosztów uzyskania przychodów na podstawie art. 22 ust. 9 pkt 3 ustawy."></ea:framelabel>
<ea:framelabel id="Framelabel49" style="Z-INDEX: 178; LEFT: 252px; POSITION: absolute; TOP: 1084px; width: 77px; height: 56px;" SmallerFontLength="18"
				runat="server" ValueStyle="ZlGr" DataMember="E.1aPrzychód" Number="29"></ea:framelabel>
<ea:framelabel id="Framelabel51" style="Z-INDEX: 179; LEFT: 329px; POSITION: absolute; TOP: 1084px; width: 75px; height: 58px;" SmallerFontLength="18"
				runat="server" ValueStyle="ZlGr" DataMember="E.1aKoszty" Number="30"></ea:framelabel>
<ea:framelabel id="Framelabel53" style="Z-INDEX: 180; LEFT: 406px; POSITION: absolute; TOP: 1084px; width: 78px; height: 87px;" SmallerFontLength="18"
				runat="server" ValueStyle="ZlGr" DataMember="E.1Dochód" 
                Number="31"></ea:framelabel>
<ea:framelabel id="Framelabel154" style="Z-INDEX: 180; LEFT: 483px; POSITION: absolute; TOP: 1084px; width: 78px; height: 85px;" SmallerFontLength="18"
				runat="server" ValueStyle="ZlGr" DataMember="E.1Zwolniony" 
                Number="32"></ea:framelabel>
<ea:framelabel id="Framelabel54" style="Z-INDEX: 181; LEFT: 560px; POSITION: absolute; TOP: 1084px; width: 73px; height: 86px;"
				runat="server" ValueStyle="Zl" DataMember="E.1Zaliczka" 
                Number="33"></ea:framelabel>
<ea:framelabel id="Framelabel50" style="Z-INDEX: 182; LEFT: 252px; POSITION: absolute; TOP: 1140px; width: 76px; height: 25px;" SmallerFontLength="18"
				runat="server" ValueStyle="ZlGr" DataMember="E.1bPrzychód" 
                Number="34" CssClass="style1"></ea:framelabel>
<ea:framelabel id="Framelabel52" style="Z-INDEX: 183; LEFT: 329px; POSITION: absolute; TOP: 1140px; width: 76px;"
				runat="server" ValueStyle="ZlGr" DataMember="E.1bKoszty" Height="28px" 
                Number="35"></ea:framelabel>
<ea:framelabel id="FrameLabel55" style="Z-INDEX: 184; LEFT: 28px; POSITION: absolute; TOP: 1168px; height: 45px; width: 221px;"
				runat="server" Text="Należności z tytułu członkostwa w rolniczej spółdzielni produkcyjnej lub innej spółdzielni zajmującej się produkcją rolną oraz zasiłki pieniężne z ubezpieczenia społecznego"
				FrameStyle="SmallBoldYellow" Number="2" HorizontalAlign="Left"></ea:framelabel>
<ea:framelabel id="Framelabel57" style="Z-INDEX: 185; LEFT: 252px; POSITION: absolute; TOP: 1168px; width: 78px; height: 45px;"
				runat="server" ValueStyle="ZlGr" DataMember="E.2Przychód" 
                Number="36"></ea:framelabel>
<ea:framelabel id="Framelabel59" style="Z-INDEX: 186; LEFT: 406px; POSITION: absolute; TOP: 1168px; width: 77px; height: 44px;"
				runat="server" ValueStyle="ZlGr" DataMember="E.2Dochód" 
                Number="37" CssClass="style1"></ea:framelabel>
<ea:framelabel id="Framelabel60" style="Z-INDEX: 187; LEFT: 560px; POSITION: absolute; TOP: 1168px; width: 70px; height: 41px;"
				runat="server" ValueStyle="Zl" DataMember="E.2Zaliczka" 
                Number="38"></ea:framelabel>
<ea:framelabel id="FrameLabel61" style="Z-INDEX: 190; LEFT: 28px; POSITION: absolute; TOP: 1210px; width: 221px;"
				runat="server" Height="25px" Text="Emerytury - renty zagraniczne" 
                FrameStyle="SmallBoldYellow" Number="3" HorizontalAlign="Left"></ea:framelabel>
<ea:framelabel id="Framelabel62" style="Z-INDEX: 191; LEFT: 252px; POSITION: absolute; TOP: 1210px; width: 75px;"
				runat="server" ValueStyle="ZlGr" DataMember="E.3Przychód" Height="28px" 
                Number="39"></ea:framelabel>
<ea:framelabel id="Framelabel64" style="Z-INDEX: 192; LEFT: 406px; POSITION: absolute; TOP: 1210px; width: 79px;"
				runat="server" ValueStyle="ZlGr" DataMember="E.3Dochód" Height="28px" 
                Number="40"></ea:framelabel>
<ea:framelabel id="Framelabel156" style="Z-INDEX: 193; LEFT: 483px; POSITION: absolute; TOP: 1210px; width: 79px;"
				runat="server" ValueStyle="ZlGr" DataMember="E.3Zwolniony" Height="28px" 
                Number="41"></ea:framelabel>
<ea:framelabel id="Framelabel65" style="Z-INDEX: 194; LEFT: 560px; POSITION: absolute; TOP: 1210px; width: 71px;"
				runat="server" ValueStyle="Zl" DataMember="E.3Zaliczka" Height="28px" 
                Number="42"></ea:framelabel>
<ea:framelabel id="FrameLabel66" style="Z-INDEX: 195; LEFT: 28px; POSITION: absolute; TOP: 1238px; height: 26px; width: 221px;"
				runat="server" 
                Text="Należności za pracę przypadające tymczasowo aresztowanym lub skazanym" 
                FrameStyle="SmallBoldYellow" Number="4" HorizontalAlign="Left"></ea:framelabel>
<ea:framelabel id="Framelabel72" style="Z-INDEX: 196; LEFT: 252px; POSITION: absolute; TOP: 1238px; right: 591px; width: 80px;"
				runat="server" ValueStyle="ZlGr" DataMember="E.4Przychód" Height="28px" 
                Number="43" CssClass="style1"></ea:framelabel>
<ea:framelabel id="Framelabel85" style="Z-INDEX: 197; LEFT: 406px; POSITION: absolute; TOP: 1238px; width: 74px;"
				runat="server" ValueStyle="ZlGr" DataMember="E.4Dochód" Height="28px" 
                Number="44" CssClass="style1"></ea:framelabel>
<ea:framelabel id="Framelabel91" style="Z-INDEX: 198; LEFT: 560px; POSITION: absolute; TOP: 1238px; width: 72px;"
				runat="server" ValueStyle="Zl" DataMember="E.4Zaliczka" Height="28px" 
                Number="45"></ea:framelabel>
<ea:framelabel id="FrameLabel67" style="Z-INDEX: 199; LEFT: 28px; POSITION: absolute; TOP: 1266px; height: 26px; width: 225px;"
				runat="server" 
                Text="Świadczenia wypłacone z Funduszów<br>Pracy i Gwarantowanych Świadczeń Pracowniczych" 
                FrameStyle="SmallBoldYellow" Number="5" HorizontalAlign="Left"></ea:framelabel>
<ea:framelabel id="Framelabel73" style="Z-INDEX: 200; LEFT: 252px; POSITION: absolute; TOP: 1266px; width: 77px;"
				runat="server" ValueStyle="ZlGr" DataMember="E.5Przychód" Height="26px" 
                Number="46"></ea:framelabel>
<ea:framelabel id="Framelabel86" style="Z-INDEX: 201; LEFT: 406px; POSITION: absolute; TOP: 1266px; width: 79px;"
				runat="server" ValueStyle="ZlGr" DataMember="E.5Dochód" Height="28px" 
                Number="47"></ea:framelabel>
<ea:framelabel id="Framelabel92" style="Z-INDEX: 202; LEFT: 560px; POSITION: absolute; TOP: 1266px; width: 69px;"
				runat="server" ValueStyle="Zl" DataMember="E.5Zaliczka" Height="26px" 
                Number="48"></ea:framelabel>
<ea:framelabel id="FrameLabel97" style="Z-INDEX: 203; LEFT: 28px; POSITION: absolute; TOP: 1294px; height: 39px; width: 222px;"
				runat="server" Text="Działalność wykonywana osobiście, o której mowa w art. 13 pkt 2, 4, 6 (z wyjątkiem czynności wymienionych w wierszu 7) i 7-9 ustawy, w tym umowy zlecenia i o dzieło&lt;./&gt;"
				FrameStyle="SmallBoldYellow" Number="6" HorizontalAlign="Left"></ea:framelabel>
<ea:framelabel id="Framelabel74" style="Z-INDEX: 203; LEFT: 252px; POSITION: absolute; TOP: 1294px; width: 75px; height: 40px;"
				runat="server" ValueStyle="ZlGr" DataMember="E.6Przychód" 
                Number="49"></ea:framelabel>
<ea:framelabel id="Framelabel100" style="Z-INDEX: 203; LEFT: 329px; POSITION: absolute; TOP: 1294px; width: 76px; height: 40px;"
				runat="server" ValueStyle="ZlGr" DataMember="E.6Koszty" 
                Number="50"></ea:framelabel>
<ea:framelabel id="Framelabel87" style="Z-INDEX: 203; LEFT: 406px; POSITION: absolute; TOP: 1294px; width: 79px; right: 482px; height: 40px;"
				runat="server" ValueStyle="ZlGr" DataMember="E.6Dochód" 
                Number="51"></ea:framelabel>
<ea:framelabel id="Framelabel93" style="Z-INDEX: 204; LEFT: 560px; POSITION: absolute; TOP: 1294px; width: 69px; height: 41px;"
				runat="server" ValueStyle="Zl" DataMember="E.6Zaliczka" 
                Number="52"></ea:framelabel>
<ea:framelabel id="FrameLabel68" style="Z-INDEX: 205; LEFT: 28px; POSITION: absolute; TOP: 1336px; width: 222px;"
				runat="server" Height="26px" 
                Text="Czynności związane z pełnieniem obowiązków społeczych lub obywatelskich (art. 13 pkt 5 i 6 ustawy) - <.Normal>Należy wpisać kwotę wynikające z PIT-R<./>" FrameStyle="SmallBoldYellow"
				Number="7" HorizontalAlign="Left"></ea:framelabel>
<ea:framelabel id="Framelabel98" style="Z-INDEX: 206; LEFT: 252px; POSITION: absolute; TOP: 1336px; right: 591px; width: 78px;"
				runat="server" ValueStyle="ZlGr" DataMember="E.7Przychód" Height="28px" 
                Number="53" CssClass="style1"></ea:framelabel>
<ea:framelabel id="Framelabel80" style="Z-INDEX: 207; LEFT: 329px; POSITION: absolute; TOP: 1336px; width: 76px;"
				runat="server" ValueStyle="ZlGr" DataMember="E.7Koszty" Height="28px" 
                Number="54" CssClass="style1"></ea:framelabel>
<ea:framelabel id="Framelabel118" style="Z-INDEX: 208; LEFT: 406px; POSITION: absolute; TOP: 1336px; width: 74px; bottom: 428px;"
				runat="server" ValueStyle="ZlGr" DataMember="E.7Dochód" Height="28px" 
                Number="55"></ea:framelabel>
<ea:framelabel id="Framelabel120" style="Z-INDEX: 209; LEFT: 560px; POSITION: absolute; TOP: 1336px; bottom: 481px; width: 69px;"
				runat="server" ValueStyle="Zl" DataMember="E.7Zaliczka" Height="28px" 
                Number="56"></ea:framelabel>
<ea:framelabel id="FrameLabel126" style="Z-INDEX: 210; LEFT: 28px; POSITION: absolute; TOP: 1364px; width: 226px;"
				runat="server" Height="56px" 
                Text="Prawa autorskie i inne prawa, o których mowa w art. 18 ustawy" 
                FrameStyle="SmallBoldYellow" Number="8" HorizontalAlign="Left"
                FooterText="W poz. 60 należy wykazać przychody, do których zastosowano koszty uzyskania przychodów na podstawie art. 22 ust. 9 pkt 1-3 ustawy."></ea:framelabel>
<ea:framelabel id="Framelabel135" style="Z-INDEX: 211; LEFT: 252px; POSITION: absolute; TOP: 1364px; width: 79px;"
				runat="server" ValueStyle="ZlGr" DataMember="E.8Przychód" Height="28px" 
                Number="57"></ea:framelabel>
<ea:framelabel id="Framelabel141" style="Z-INDEX: 213; LEFT: 406px; POSITION: absolute; TOP: 1364px; width: 78px;"
				runat="server" ValueStyle="ZlGr" DataMember="E.8Dochód" Height="56px" 
                Number="58"></ea:framelabel>
<ea:framelabel id="Framelabel143" style="Z-INDEX: 214; LEFT: 560px; POSITION: absolute; TOP: 1364px; width: 72px;"
				runat="server" ValueStyle="Zl" DataMember="E.8Zaliczka" Height="56px" 
                Number="59"></ea:framelabel>
<ea:framelabel id="Framelabel2" style="Z-INDEX: 215; LEFT: 252px; POSITION: absolute; TOP: 1392px; width: 76px; height: 28px;" SmallerFontLength="18"
				runat="server" ValueStyle="ZlGr" DataMember="E.8bPrzychód" 
                Number="60" CssClass="style1"></ea:framelabel>
<ea:framelabel id="Framelabel5" style="Z-INDEX: 216; LEFT: 329px; POSITION: absolute; TOP: 1392px; width: 76px;"
				runat="server" ValueStyle="ZlGr" Height="28px" DataMember="E.8Koszty"
                Number="61"></ea:framelabel>
<ea:framelabel id="Framelabel71" style="Z-INDEX: 220; LEFT: 28px; POSITION: absolute; TOP: 1420px; width: 223px;"
				runat="server" Height="26px" FrameStyle="SmallBoldYellow" 
                HorizontalAlign="Left" Number="9" 
                Text="Należności wynikające z umowy aktywizacyjnej">
                </ea:FrameLabel>
<ea:framelabel id="Framelabel90" style="Z-INDEX: 221; LEFT: 252px; POSITION: absolute; TOP: 1420px; width: 79px;"
				runat="server" ValueStyle="ZlGr" DataMember="E.9Przychód" Height="28px" 
                Number="62">
            </ea:FrameLabel>
<ea:framelabel id="Framelabel96" style="Z-INDEX: 222; LEFT: 329px; POSITION: absolute; TOP: 1420px; width: 75px;"
				runat="server" ValueStyle="ZlGr" DataMember="E.9Koszty" Height="28px" 
                Number="63">
            </ea:FrameLabel>
<ea:framelabel id="Framelabel145" style="Z-INDEX: 223; LEFT: 406px; POSITION: absolute; TOP: 1420px; width: 76px;"
				runat="server" ValueStyle="ZlGr" DataMember="E.9Dochód" Height="28px" 
                Number="64">
            </ea:FrameLabel>
<ea:framelabel id="Framelabel146" style="Z-INDEX: 224; LEFT: 560px; POSITION: absolute; TOP: 1420px; width: 69px;"
				runat="server" ValueStyle="Zl" DataMember="E.9Zaliczka" Height="28px" 
                Number="65"></ea:framelabel>
<ea:framelabel id="FrameLabel70" style="Z-INDEX: 225; LEFT: 28px; POSITION: absolute; TOP: 1448px; width: 222px;"
				runat="server" Height="26px" FrameStyle="SmallBoldYellow" 
                HorizontalAlign="Left" Number="10" Text="Inne źródła"></ea:framelabel>
<ea:framelabel id="Framelabel76" style="Z-INDEX: 226; LEFT: 252px; POSITION: absolute; TOP: 1448px; width: 78px;"
				runat="server" ValueStyle="ZlGr" DataMember="E.10Przychód" Height="28px" 
                Number="66"></ea:framelabel>
<ea:framelabel id="Framelabel89" style="Z-INDEX: 227; LEFT: 406px; POSITION: absolute; TOP: 1448px; width: 78px;"
				runat="server" ValueStyle="ZlGr" DataMember="E.10Dochód" Height="28px" 
                Number="67" CssClass="style1"></ea:framelabel>
<ea:framelabel id="Framelabel157" style="Z-INDEX: 227; LEFT: 483px; POSITION: absolute; TOP: 1448px; width: 78px;"
				runat="server" ValueStyle="ZlGr" DataMember="E.10Zwolniony" Height="28px" 
                Number="68" CssClass="style1"></ea:framelabel>
<ea:framelabel id="Framelabel95" style="Z-INDEX: 228; LEFT: 560px; POSITION: absolute; TOP: 1448px; width: 69px;"
				runat="server" ValueStyle="Zl" DataMember="E.10Zaliczka" Height="28px" 
                Number="69"></ea:framelabel>
<ea:framelabel id="FrameLabel36" style="Z-INDEX: 229; LEFT: 35px; POSITION: absolute; TOP: 1476px; width: 389px;"
				runat="server" Height="26px" 
                Text="Składki na ubezpieczenia społeczne, o których mowa w przepisach ustawy, podlegające odliczenu od dochodu" 
                FrameStyle="SmallBoldYellow" HorizontalAlign="Left"></ea:framelabel>
<ea:framelabel id="Framelabel99" style="Z-INDEX: 230; LEFT: 427px; POSITION: absolute; TOP: 1476px"
				runat="server" Width="203px" ValueStyle="ForceZlGr" DataMember="E.Społeczne" Height="28px" 
                Number="70"></ea:framelabel>
<ea:framelabel id="FrameLabel149" style="Z-INDEX: 230; LEFT: 42px; POSITION: absolute; TOP: 1504px; width: 382px;"
				runat="server" Height="26px" FrameStyle="SmallBoldYellow" HorizontalAlign="Left" 
                Text="w tym zagraniczne, o których mowa w art. 26 ust. 1 pkt 2a ustawy"></ea:framelabel>
<ea:framelabel id="Framelabel148" style="Z-INDEX: 230; LEFT: 427px; POSITION: absolute; TOP: 1504px"
				runat="server" Width="203px" ValueStyle="ForceZlGr" DataMember="E.SpołeczneZagr" Height="28px" 
                Number="71"></ea:framelabel>
<ea:framelabel id="FrameLabel63" style="Z-INDEX: 231; LEFT: 35px; POSITION: absolute; TOP: 1532px; width: 394px;"
				runat="server" Height="28px" 
                Text="Składki na ubezpieczenie zdrowotne, o których mowa w przepisach ustawy, podlegające odliczeniu od podatku" 
                FrameStyle="SmallBoldYellow" HorizontalAlign="Left"></ea:framelabel>
<ea:framelabel id="Framelabel119" style="Z-INDEX: 232; LEFT: 427px; POSITION: absolute; TOP: 1532px"
				runat="server" Width="203px" ValueStyle="ForceZlGr" DataMember="E.ZdrDoOdlicz" 
                Height="28px" Number="72"></ea:framelabel>
<ea:framelabel id="FrameLabel151" style="Z-INDEX: 232; LEFT: 42px; POSITION: absolute; TOP: 1560px; width: 385px;"
				runat="server" Height="28px" FrameStyle="SmallBoldYellow" HorizontalAlign="Left" 
                Text="w tym zagraniczne, o których mowa w art. 27b ust. 1. pkt 2 ustawy"></ea:framelabel>
<ea:framelabel id="Framelabel150" style="Z-INDEX: 232; LEFT: 427px; POSITION: absolute; TOP: 1560px"
				runat="server" Width="203px" ValueStyle="ForceZlGr" DataMember="E.ZdrDoOdliczZagr" 
                Height="28px" Number="73"></ea:framelabel>
<ea:framelabel id="Framelabel121" style="Z-INDEX: 233; LEFT: 0px; POSITION: absolute; TOP: 1588px; height: 104px;"
				runat="server" Width="630px" 
                Text="F. &lt;font STYLE='font-size: 10pt;'&gt;INFORMACJA O PRZYCHODACH ZWOLNIONYCH OD PODATKU ORAZ O ZAŁĄCZNIKU&lt;/font&gt;" 
                FrameStyle="BigYellowBold" FrameBorderStyle="DoubleHeader"></ea:framelabel>
<ea:framelabel id="FrameLabel58" style="Z-INDEX: 235; LEFT: 28px; POSITION: absolute; TOP: 1609px"
				runat="server" Width="399px" Height="28px" 
                Text="Przychody otrzymywane z zagranicy, o których mowa w art. 21 ust. 1 pkt 74 ustawy, między innymi renty inwalidzkie z tytułu inwalidztwa wojennego" FrameStyle="SmallBoldYellow"
				HorizontalAlign="Left"></ea:framelabel>
<ea:framelabel id="Framelabel78" style="Z-INDEX: 235; LEFT: 427px; POSITION: absolute; TOP: 1609px"
				runat="server" Width="203px" ValueStyle="ForceZlGr" DataMember="F.ZZagranicy" Height="28px" 
                Number="74"></ea:framelabel>
<ea:framelabel id="FrameLabel79" style="Z-INDEX: 236; LEFT: 28px; POSITION: absolute; TOP: 1637px"
				runat="server" Width="399px" Height="28px" Text="Przychody pochodzące ze środków bezzwrotnej pomocy zagranicznej, o których mowa w art. 21 ust. 1 pkt 46 ustawy"
				FrameStyle="SmallBoldYellow" HorizontalAlign="Left"></ea:framelabel>
<ea:framelabel id="Framelabel83" style="Z-INDEX: 237; LEFT: 427px; POSITION: absolute; TOP: 1637px"
				runat="server" Width="203px" ValueStyle="ForceZlGr" DataMember="F.PomocBezzwrotna" 
                Height="28px" Number="75"></ea:framelabel>
<ea:framelabel id="Framelabel137" style="Z-INDEX: 238; LEFT: 28px; POSITION: absolute; TOP: 1665px"
				runat="server" Width="602px" Height="28px" 
                Text="Do niniejszej informacji dołączono informację PIT-R <.Normal>(należy zaznaczyć właściwy kwadrat):<./>" 
                Number="76"></ea:framelabel>
<ea:checklabel id="Checklabel_82_T" style="Z-INDEX: 239; LEFT: 161px; POSITION: absolute; TOP: 1672px"
				runat="server" Width="35px" DataMember="F.PITR" Height="14px" Text="tak" Number="1" 
                NumberAlignLeft="False"></ea:checklabel>
<ea:checklabel id="Checklabel_82_N" style="Z-INDEX: 240; LEFT: 328px; POSITION: absolute; TOP: 1674px"
				runat="server" Width="35px" DataMember="F.PITR" Height="14px" Text="nie" Number="2" 
                NumberAlignLeft="False" ComparedValue="False"></ea:checklabel>
<ea:framelabel id="FrameLabel122" style="Z-INDEX: 241; LEFT: 0px; POSITION: absolute; TOP: 1693px; height: 68px;"
				runat="server" Width="630px" Text="G. &lt;font STYLE='font-size: 10pt;'&gt;PODPIS PŁATNIKA LUB OSOBY WYZNACZONEJ DO OBLICZENIA I POBRANIA PODATKU / PEŁNOMOCNIKA PŁATNIKA&lt;/font&gt;&lt;br&gt;&lt;.Footer&gt;"
				FrameStyle="BigYellowBold" FrameBorderStyle="DoubleHeader"></ea:framelabel>
<ea:framelabel id="flGImie" style="Z-INDEX: 242; LEFT: 28px; POSITION: absolute; TOP: 1735px"
				runat="server" Width="147px" DataMember="G.Imię" Height="28px" Text="Imię" Number="77"></ea:framelabel>
<ea:framelabel id="flGNazwisko" 
                style="Z-INDEX: 244; LEFT: 175px; POSITION: absolute; TOP: 1735px; right: 501px;" SmallerFontLength="20"
				runat="server" Width="147px" DataMember="G.Nazwisko" Height="28px" Text="Nazwisko" 
                Number="78"></ea:framelabel>
<ea:framelabel id="FrameLabel124" style="Z-INDEX: 244; LEFT: 322px; POSITION: absolute; TOP: 1735px"
				runat="server" Width="308px" Height="28px" 
                Text="Podpis i pieczątka" 
                Number="79"></ea:framelabel>
<ea:framelabel id="FrameLabel127" style="Z-INDEX: 245; LEFT: 0px; POSITION: absolute; TOP: 1763px"
				runat="server" Width="630px" Height="82px" Text="H. ADNOTACJE URZĘDU SKARBOWEGO" 
                FrameStyle="BigYellowBold" FrameBorderStyle="DoubleHeader"></ea:framelabel>
<ea:framelabel id="FrameLabel130" style="Z-INDEX: 246; LEFT: 28px; POSITION: absolute; TOP: 1785px"
				runat="server" Width="602px" Height="40px" Text="Uwagi urzędu skarbowego" 
                FrameStyle="SmallBoldGray" Number="80"></ea:framelabel>
<ea:framelabel id="FrameLabel128" style="Z-INDEX: 247; LEFT: 28px; POSITION: absolute; TOP: 1826px"
				runat="server" Width="301px" Height="20px" 
                Text="Identyfikator przyjmującego formularz" FrameStyle="SmallBoldGray" 
                Number="81"></ea:framelabel>
<ea:framelabel id="FrameLabel129" style="Z-INDEX: 248; LEFT: 329px; POSITION: absolute; TOP: 1826px"
				runat="server" Width="301px" Height="20px" Text="Podpis przyjmującego formularz" 
                FrameStyle="SmallBoldGray" Number="82"></ea:framelabel>
<ea:deklaracjafooter id="footer2" 
                style="Z-INDEX: 249; LEFT: 490px; POSITION: absolute; TOP: 1907px" runat="server"
				Width="154px" Height="10px" TitleWidth="106" Symbol="PIT-11" PageNumber="2" 
                PageTotal="3" Version="23"></ea:deklaracjafooter>
<ea:framelabel id="flDanePodatnika1" style="Z-INDEX: 249; LEFT: 199px; POSITION: absolute; TOP: 1907px; height: 21px; width: 427px; right: 275px;"
				runat="server" Text="?" FrameStyle="Middle" FrameBorderStyle="None" 
                HorizontalAlign="Right" VerticalAlign="Bottom"></ea:framelabel>
<ea:deklaracjaheader id="DeklaracjaHeader3" style="Z-INDEX: 249; LEFT: 0px; POSITION: absolute; TOP: 1960px"
				runat="server" Width="630px" StylNagłówka="JasneCiemneElektroniczniePortal"></ea:deklaracjaheader>
<ea:framelabel id="FrameLabel147" style="Z-INDEX: 249; LEFT: 3px; POSITION: absolute; TOP: 1990px"
				runat="server" Width="627px" Height="24px" 
                Text="&lt;.INDEXUP&gt;1)&lt;./&gt; &lt;font STYLE='font-size: 5pt;'&gt;Art. 35a ustawy został uchylony z dniem 26 października 2007 r. ustawą z dnia 24 sierpnia 2007 r. o zmianie ustawy o promocji zatrudnienia i instytucjach rynku pracy oraz o zmianie niektórych innych ustaw (Dz. U. Nr 176, poz. 1243). Uchylony przepis na mocy art. 7 ust. 7 powołanej ustawy ma zastosowanie do płatników do czasu obowiązywania umowy aktywizacyjnej zawartej przed dniem 26 października 2007 r." 
                FrameStyle="Small" FrameBorderStyle="None">
                </ea:FrameLabel>
<ea:framelabel id="FrameLabel132" style="Z-INDEX: 250; LEFT: 3px; POSITION: absolute; TOP: 2012px"
				runat="server" Width="627px" Height="21px" 
                Text="&lt;.INDEXUP&gt;2)&lt;./&gt; &lt;font STYLE='font-size: 5pt;'&gt;Ilekroć w deklaracji jest mowa o urzędzie skarbowym, w tym urzędzie skarbowym, do którego adresowana jest informacja - oznacza to urząd skarbowy, przy pomocy którego właściwy dla podatnika naczelnik urzędu skarbowego wykonuje swoje zadania." 
                FrameStyle="Small" FrameBorderStyle="None">
                </ea:FrameLabel>
<ea:framelabel id="Framelabel131" style="Z-INDEX: 251; LEFT: 3px; POSITION: absolute; TOP: 2034px; height: 24px;"
				runat="server" Width="627px" 
                Text="&lt;.INDEXUP&gt;3)&lt;./&gt; &lt;font STYLE='font-size: 5pt;'&gt;Zgodnie z art. 81 ustawy z dnia 29 sierpnia 1997 r. - Ordynacja podatkowa (Dz. U. z 2015 r. poz. 613, późn. zm.)." 
                FrameStyle="Small" FrameBorderStyle="None"></ea:framelabel>
<ea:framelabel id="Framelabel8" style="Z-INDEX: 251; LEFT: 3px; POSITION: absolute; TOP: 2048px; height: 18px;"
				runat="server" Width="627px" 
                Text="&lt;.INDEXUP&gt;4)&lt;./&gt; &lt;font STYLE='font-size: 5pt;'&gt;W przypadku zaznaczenia kwadratu nr 2, w poz. 18-27 należy podać kraj inny niż Rzeczpospolita Polska oraz adres zamieszkania za granicą; dodatkowo kod kraju wydania dokumentu powinien być zgodny z krajem adresu zamieszkania." 
                FrameStyle="Small" FrameBorderStyle="None"></ea:framelabel>
<ea:framelabel id="Framelabel10" style="Z-INDEX: 251; LEFT: 3px; POSITION: absolute; TOP: 2068px; height: 18px;"
				runat="server" Width="627px" 
                Text="&lt;.INDEXUP&gt;5)&lt;./&gt; &lt;font STYLE='font-size: 5pt;'&gt;W poz. 12 należy podać numer służący identyfikacji dla celów podatkowych lub ubezpieczeń społecznych uzyskany w państwie, w którym podatnik ma miejsce zamieszkania. W przypadku braku takiego numeru w poz. 12 należy podać numer dokumentu stwierdzającego tożsamość podatnika, uzyskanego w tym państwie." 
                FrameStyle="Small" FrameBorderStyle="None"></ea:framelabel>
<ea:framelabel id="Framelabel13" style="Z-INDEX: 251; LEFT: 3px; POSITION: absolute; TOP: 2088px; height: 18px;"
				runat="server" Width="627px" 
                Text="&lt;.INDEXUP&gt;6)&lt;./&gt; &lt;font STYLE='font-size: 5pt;'&gt;Poz. 13 i 14 wypełnia płatnik, który w poz. 12 podał zagraniczny numer identyfikacyjny podatnika." 
                FrameStyle="Small" FrameBorderStyle="None"></ea:framelabel>
<ea:framelabel id="FrameLabel133" style="Z-INDEX: 252; LEFT: 3px; POSITION: absolute; TOP: 2101px; height: 18px;"
				runat="server" Width="627px" 
                Text="&lt;.INDEXUP&gt;7)&lt;./&gt; &lt;font STYLE='font-size: 5pt;'&gt;W kwocie przychodów, w części E, nie uwzględnia się przychodów wolnych od podatku na podstawie przepisów ustawy oraz przychodów, od których na podstawie przepisów Ordynacji podatkowej zaniechano poboru podatku; jednakże w kolumnie e należy wykazać dochody zwolnione od podatku na podstawie umów o unikaniu podwójnego opodatkowania lub innych umów międzynarodowych." 
                FrameStyle="Small" FrameBorderStyle="None"></ea:framelabel>
<ea:framelabel id="Framelabel35" style="Z-INDEX: 253; LEFT: 3px; POSITION: absolute; TOP: 2126px"
				runat="server" Width="627px" Height="6px" 
                Text="&lt;.INDEXUP&gt;8)&lt;./&gt; &lt;font STYLE='font-size: 5pt;'&gt;W kwocie kosztów uzyskania przychodu wykazuje się koszty faktycznie uwzględnione przez płatnika przy poborze zaliczek na podatek." 
                FrameStyle="Small" FrameBorderStyle="None"></ea:framelabel>
<ea:framelabel id="FrameLabel56" style="Z-INDEX: 254; LEFT: 3px; POSITION: absolute; TOP: 2139px; height: 26px;"
				runat="server" Width="627px"                                 
                Text="&lt;.INDEXUP&gt;9)&lt;./&gt; &lt;font STYLE='font-size: 5pt;'&gt;W poz. 70-73 nie wykazuje się składek, których podstawę wymiaru stanowi dochód (przychód) zwolniony od podatku na podstawie ustawy oraz składek, których podstawę wymiaru stanowi dochód, od którego na podstawie przepisów Ordynacji podatkowej zaniechano poboru podatku, a w przypadku składek zagranicznych, których podstawę wymiaru stanowi dochód (przychód) zwolniony od podatku na podstawie umów o unikaniu podwójnego opodatkowania." FrameStyle="Small"
				FrameBorderStyle="None"></ea:framelabel>
<ea:framelabel id="FrameLabel6" style="Z-INDEX: 256; LEFT: 300px; POSITION: absolute; TOP: 2183px"
				runat="server" Width="327px" Height="6px" Text="&lt;font STYLE='font-size: 5pt;'&gt;&lt;b&gt;Pouczenie&lt;/b&gt;"
				FrameStyle="Small" FrameBorderStyle="None"></ea:framelabel>
<ea:framelabel id="FrameLabel7" style="Z-INDEX: 257; LEFT: 3px; POSITION: absolute; TOP: 2194px"
				runat="server" Width="627px" Height="6px" Text="&lt;font STYLE='font-size: 5pt;'&gt;Za uchybienie obowiązkom płatnika grozi odpowiedzialność przewidziana w Kodeksie karnym skarbowym."
				FrameStyle="Small" FrameBorderStyle="None"></ea:framelabel>
<ea:framelabel id="flDanePodatnika2" style="Z-INDEX: 258; LEFT: 199px; POSITION: absolute; TOP: 2214px; height: 21px; width: 427px; right: 275px;"
				runat="server" Text="?" FrameStyle="Middle" FrameBorderStyle="None" 
                HorizontalAlign="Right" VerticalAlign="Bottom"></ea:framelabel>
<ea:deklaracjafooter id="footer3" 
                style="Z-INDEX: 259; LEFT: 0px; POSITION: absolute; TOP: 2887px" runat="server"
				TitleWidth="106" Symbol="PIT-11" PageNumber="3" PageTotal="3" Version="23"></ea:deklaracjafooter>
<ea:datacontext id="dc" style="Z-INDEX: 260; LEFT: 189px; POSITION: absolute; TOP: 2887px" runat="server"
				TypeName="Soneta.Deklaracje.PIT.PIT11,Soneta.Deklaracje" oncontextload="OnContextLoad" 
                LeftMargin="15" PageHeight="977px" PageZoom="106%"></ea:datacontext>
<ea:Section ID="Strony" runat="server">
<ea:framelabel id="Framelabel14" style="Z-INDEX: 270; LEFT: 0px; POSITION: absolute; TOP: 3000px; height: 1px; width: 601px;"
				runat="server" Text="" FrameBorderStyle="None"></ea:framelabel>
</ea:Section>
</form>
	</body>
</HTML>

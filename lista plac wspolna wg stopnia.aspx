<%@ Page Language="c#" CodePage="1200" %>
<%@ Register TagPrefix="ea" Namespace="Soneta.Web" Assembly="Soneta.Web" %>
<%@ Register TagPrefix="cc1" Namespace="Soneta.Core.Web" Assembly="Soneta.Core.Web" %>
<%@ import Namespace="Soneta.Business" %>
<%@ import Namespace="Soneta.Tools" %>
<%@ import Namespace="Soneta.Types" %>
<%@ import Namespace="Soneta.Kalend" %>
<%@ import Namespace="Soneta.Kadry" %>
<%@ import Namespace="Soneta.Place" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" >
<HTML>
	<HEAD>
		<title>Pełna lista płac</title>
		<script runat="server">

	//Max długość opisu z numerami list płac. 0 oznacza bez limitu.
	static int maxOpisLen = 0;

    public enum RodzajFiltra {
        Brak                    = 0,
        Lekki                   = 1,
        Umiarkowany             = 2,
        Znaczny                 = 3,
        OsobaDo16Roku           = 4,
        WszyscyNiepełnosprawni  = 1000,
        Wszyscy                 = 1001
    }
		    
    public class Params : ContextBase {
    
        public Params(Context cx) : base(cx) {
        }
    
		RodzajFiltra filtr = RodzajFiltra.Wszyscy;
        [Caption("St. niepełnosprawności")]
        [Priority(1)]
        public RodzajFiltra Filtr {
            get { return filtr; }
            set {
                filtr = value; 
				OnChanged(EventArgs.Empty);
            }
		}
    
        bool paski = false;    
        [Caption("Osobne paski wypłat")]
        [Priority(2)]
        public bool Paski {
            get { return paski; }
            set { 
				paski = value; 
				OnChanged(EventArgs.Empty);
            }
        }
    
        bool sumy = false;
        [Caption("Suma dla pracownika")]
        [Priority(3)]
        public bool Sumy {
            get { return sumy; }
            set { 
				sumy = value; 
				OnChanged(EventArgs.Empty);
			}
        }
    }

    public class SrParams : SerializableContextBase {
        public SrParams(Context context) : base(context) {
        }

        //static bool fundusze = false;
        bool fundusze = false;
        [Priority(1)]
        [Caption("Fundusze")]
        public bool Fundusze {
            get { return fundusze; }
            set {
                fundusze = value;
                OnChanged(EventArgs.Empty);
            }
        }

        //static bool hideOperator = false;
        bool hideOperator = false;
        [Priority(2)]
        [Caption("Ukryj operatora")]
        public bool HideOperator {
            get { return hideOperator; }
            set {
                hideOperator = value;
                OnChanged(EventArgs.Empty);
            }
        }

        //static bool procentInfo = false;
        bool procentInfo = false;
        [Priority(3)]
        [Caption("Informacja %")]
        public bool ProcentInfo {
            get { return procentInfo; }
            set {
                procentInfo = value;
                OnChanged(EventArgs.Empty);
            }
        }

        //static bool skladnikiInfo = false;
        bool skladnikiInfo = false;
        [Priority(4)]
        [Caption("Składniki")]
        public bool SkladnikiInfo {
            get { return skladnikiInfo; }
            set {
                skladnikiInfo = value;
                OnChanged(EventArgs.Empty);
            }
        }

        //static bool procentPit = false;
        bool procentPit = false;
        [Priority(5)]
        [Caption("Procent PIT")]
        public bool ProcentPit {
            get { return procentPit; }
            set {
                procentPit = value;
                OnChanged(EventArgs.Empty);
            }
        }

        //static bool pracaInfo = false;
        bool pracaInfo = false;
        [Priority(6)]
        [Caption("Informacja o pracy")]
        public bool PracaInfo {
            get { return pracaInfo; }
            set {
                pracaInfo = value;
                OnChanged(EventArgs.Empty);
            }
        }

        //static bool stanowiskoInfo = false;
        bool stanowiskoInfo = false;
        [Priority(7)]
        [Caption("Stanowiska")]
        public bool StanowiskoInfo {
            get { return stanowiskoInfo; }
            set {
                stanowiskoInfo = value;
                OnChanged(EventArgs.Empty);
            }
        }

        bool pelneStanowisko = false;
        [Priority(8)]
        [Caption("Stanowisko pełna nazwa")]
        public bool PelneStanowisko {
            get { return pelneStanowisko; }
            set {
                pelneStanowisko = value;
                OnChanged(EventArgs.Empty);
            }
        }

        bool stnKadrowe = false;
        [Priority(9)]
        [Caption("St.niepeł. z danych kadr.")]
        public bool StnKadrowe {
            get { return stnKadrowe; }
            set {
                stnKadrowe = value;
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
		                            
    Currency brutto = 0;
    Currency wyplata = 0;
    Hashtable elements = new Hashtable();
    
    decimal sumaEmerPrac = 0;
    decimal sumaRentPrac = 0;
    decimal sumaChorPrac = 0;
    decimal sumaWypadPrac = 0;
    decimal sumaZdrowPrac = 0;
    decimal sumaEmerFirma = 0;
    decimal sumaRentFirma = 0;
    decimal sumaChorFirma = 0;
    decimal sumaWypadFirma = 0;
    decimal sumaZdrowFirma = 0;
    decimal sumaFP = 0;
    decimal sumaFGSP = 0;
    decimal sumaFEP = 0;
    decimal sumaZaliczka = 0;
    decimal sumaKoszty = 0;
    decimal sumaUlga = 0;
    Currency sumaGotowka = 0;
    Currency sumaROR = 0;
    
    public class Elem : IComparable {
        int counter = 0;
        string name;
        decimal dodatki = 0;
        decimal potrącenia = 0;
    
        public Elem(DefinicjaElementu definicja) {
            this.name = definicja.Nazwa;
        }
    
        public void Add(decimal wartość) {
            ++counter;
            if (wartość>0)
                dodatki += wartość;
            else
                potrącenia -= wartość;
        }
    
        public int Counter { get { return counter; } }
        public string Name { get { return name; } }
        public decimal Dodatki { get { return dodatki; } }
        public decimal Potrącenia { get { return potrącenia; } }
        public decimal Razem { get { return dodatki-potrącenia; } }
    
        public int CompareTo(object v) {
            return string.Compare(Name, ((Elem)v).Name, true);
        }
    }
    
	static readonly string prefix = "&nbsp;&nbsp;";
    
    private void Grid_BeforeRow(object sender, Soneta.Web.RowEventArgs args) {
        Wyplata wypłata = (Wyplata)args.Row;
    
        string ss = string.Format("<strong>{0}<br>{1}</strong>",
            wypłata.PracHistoria.Nazwisko,
            wypłata.PracHistoria.Imie);
    
		if (srpars.StanowiskoInfo)
			ss += "<br>" + GetStanowisko(wypłata.Pracownik[wypłata.ListaPlac.Okres.To]);
		
        if (srpars.PracaInfo || srpars.ProcentPit) {
			
			string c1 = "";
			string c2 = "";
			
			if (srpars.ProcentPit) {
				Percent ppit = wypłata.Pracownik.PrógPodatkowy(new YearMonth(wypłata.Data));
				c1 = "Procent zal.podatku:";
				c2 = ppit.ToString();
			}
			
			if (srpars.PracaInfo) {
				string who = wypłata.Pracownik.Last.Plec==PłećOsoby.Kobieta ? "Przepracowała" : "Przepracował";
				Time czas = Time.Zero;
				Time noc = Time.Zero;
				Time n50 = Time.Zero;
				Time n100 = Time.Zero;
				int ch = 0;
				int uw = 0;
				int pn = 0;
				
				foreach (WypElement element in wypłata.Elementy)
					switch (element.RodzajZrodla) {
						case RodzajŹródłaWypłaty.Etat:
							czas += element.Czas;
							foreach (WypSkladnik skl in element.Skladniki) {
								WypSkladnikPomniejszenie pomn = skl as WypSkladnikPomniejszenie;
								if (pomn!=null && pomn.Nieobecnosc!=null)
									if (pomn.Nieobecnosc.Definicja.Typ==TypNieobecnosci.NieobecnośćZUS)
										ch += pomn.Okres.Days;
									else if (pomn.Nieobecnosc.Definicja.Przyczyna==PrzyczynaNieobecnosci.UrlopWypoczynkowy)
										uw -= pomn.Dni;
									else
										pn -= pomn.Dni;
							}
							break;						
						case RodzajŹródłaWypłaty.Nocne:
							noc += element.Czas;
							break;						
						case RodzajŹródłaWypłaty.NadgodzinyI:
							n50 += element.Czas;
							break;						
						case RodzajŹródłaWypłaty.NadgodzinyII:
						case RodzajŹródłaWypłaty.NadgodzinyŚw:
							n100 += element.Czas;
							break;
                        case RodzajŹródłaWypłaty.Odchyłki:
                            czas += element.Czas;
                            break;
					}
				
				
				if (srpars.ProcentPit) {
					c1 += "<br>";
					c2 += "<br>";
				}
				
				c1 += who + ":";
				c2 += "" + czas;
				
				if (noc!=Time.Zero) {
					c1 += "<br>&nbsp;&nbsp;nocne:";
					c2 += "<br>" + noc;
				}
				
				if (n50!=Time.Zero) {
					c1 += "<br>&nbsp;&nbsp;nadgodziny 50%:";
					c2 += "<br>" + n50;
				}
				
				if (n100!=Time.Zero) {
					c1 += "<br>&nbsp;&nbsp;nadgodziny 100%:";
					c2 += "<br>" + n100;
				}

				if (ch!=0 || uw!=0 || pn!=0) 
					if (ch==0 && uw==0) {
						c1 += "<br>Nieobecności:";
						c2 += "<br>" + pn;
					}
					else {
						c1 += "<br>Nieobecności";
						c2 += "<br>";
						
						if (ch!=0) {
							c1 += "<br>&nbsp;&nbsp;zwol.lekarskie:";
							c2 += "<br>" + ch;
						}
						if (uw!=0) {
							c1 += "<br>&nbsp;&nbsp;url.wypoczynkowe:";
							c2 += "<br>" + uw;
						}
						if (pn!=0) {
							c1 += "<br>&nbsp;&nbsp;pozostałe:";
							c2 += "<br>" + pn;
						}
					}
			}
			
			ss += "<table width='100%'>";
			ss += "<tr><td><font size=1>"+c1+"</font></td><td align='right'><font size=1>"+c2+"</td></tr>";
			ss += "</table>";
        }
    
        colNazImie.EditValue = ss;
    
        colOkres.EditValue = wypłata.ListaPlac.Okres;
    
        decimal emerP = 0, rentP = 0, chorP = 0, wypadP = 0;
        decimal emerF = 0, rentF = 0, chorF = 0, wypadF = 0;
        decimal fis = 0, zdrow = 0, koszty = 0, ulga = 0;
        decimal sumaOpodat = 0, sumaNieOpodat = 0;
        decimal fp = 0, fgsp = 0, fep=0;
        foreach (WypElement element in wypłata.ElementyWgKolejności) {
			bool opodatkowany = element.Definicja.Deklaracje.Zaliczka.Typ!=TypZaliczkiPodatku.NieNaliczać;
            if (!srpars.SkladnikiInfo) {
                if (element.DoOpodatkowania != 0 || element.NiePodlegaOpodatkowaniu != 0) {
                    if (srpars.ProcentInfo && element.SkładnikGłówny != null && element.SkładnikGłówny.Procent != 0) {
                        Percent v = element.SkładnikGłówny.Procent;
                        if (Soneta.Tools.Math.RoundCy((decimal)v) == (decimal)v)
                            colElementy.AddLine(element.Nazwa + ",&nbsp;" + (int)(100 * (decimal)v) + "%");
                        else
                            colElementy.AddLine(element.Nazwa + ",&nbsp;" + v);
                    }
                    else
                        colElementy.AddLine(element.Nazwa);

                    if (element.DoOpodatkowania != 0)
                        colOpodat.AddLine("{0:n}", element.DoOpodatkowania);
                    else
                        colOpodat.AddLine();

                    if (element.NiePodlegaOpodatkowaniu != 0)
                        colNieOpodat.AddLine("{0:n}", element.NiePodlegaOpodatkowaniu);
                    else
                        colNieOpodat.AddLine();

                }
            }
            else
                foreach (WypSkladnik sk in element.Skladniki) {
                    WypSkladnikGłówny skg = sk as WypSkladnikGłówny;
                    bool addempty = false;
                    if (skg != null) {
                        if (srpars.ProcentInfo && skg.Procent != 0) {
                            Percent v = skg.Procent;
                            if (Soneta.Tools.Math.RoundCy((decimal)v) == (decimal)v)
                                colElementy.AddLine(element.Nazwa + ",&nbsp;" + (int)(100 * (decimal)v) + "%");
                            else
                                colElementy.AddLine(element.Nazwa + ",&nbsp;" + v);
                        }
                        else
                            colElementy.AddLine(element.Nazwa);
                    }
                    else {
                        WypSkladnikPomniejszenie skp = sk as WypSkladnikPomniejszenie;
                        if (skp != null) {
                            colElementy.AddLine(prefix + skp.Nieobecnosc.Definicja.Nazwa);
                            colElementy.AddLine(prefix + prefix + "(" + skp.Okres + ")");
                            addempty = true;
                        }
                        else
                            colElementy.AddLine(prefix + CaptionAttribute.EnumToString(sk.Rodzaj));
                    }

                    decimal opodat = 0;
                    decimal nieopodat = 0;
                    if (sk.Wartosc == element.Wartosc) {
                        opodat = element.DoOpodatkowania;
                        nieopodat = element.NiePodlegaOpodatkowaniu;
                    }
                    else if (opodatkowany)
                        opodat = sk.Wartosc;
                    else
                        nieopodat = sk.Wartosc;

                    if (opodat != 0)
                        colOpodat.AddLine("{0:n}", opodat);
                    else
                        colOpodat.AddLine();

                    if (nieopodat != 0)
                        colNieOpodat.AddLine("{0:n}", nieopodat);
                    else
                        colNieOpodat.AddLine();

                    if (addempty) {
                        colNieOpodat.AddLine();
                        colOpodat.AddLine();
                    }
                }

            brutto += element.DoOpodatkowania;
            sumaOpodat += element.DoOpodatkowania;
            sumaNieOpodat += element.NiePodlegaOpodatkowaniu;
            					
            emerP += element.Podatki.Emerytalna.Prac;
            rentP += element.Podatki.Rentowa.Prac;
            chorP += element.Podatki.Chorobowa.Prac;
            wypadP += element.Podatki.Wypadkowa.Prac;
    
            emerF += element.Podatki.Emerytalna.Firma;
            rentF += element.Podatki.Rentowa.Firma;
            chorF += element.Podatki.Chorobowa.Firma;
            wypadF += element.Podatki.Wypadkowa.Firma;
    
            fis += element.Podatki.ZalFIS;
            zdrow += element.Podatki.Zdrowotna.Prac;
            koszty += element.Podatki.KosztyPIT;
            ulga += element.Podatki.Ulga;
    
            fp += element.Podatki.FP.Skladka;
            fgsp += element.Podatki.FGSP.Skladka;
            fep += element.Podatki.FEP.Skladka;
    
            Elem elem = (Elem)elements[element.Definicja];
            if (elem==null) {
                elem = new Elem(element.Definicja);
                elements[element.Definicja] = elem;
            }
            elem.Add(element.Wartosc);
    
            sumaEmerPrac += element.Podatki.Emerytalna.Prac;
            sumaRentPrac += element.Podatki.Rentowa.Prac;
            sumaChorPrac += element.Podatki.Chorobowa.Prac;
            sumaWypadPrac += element.Podatki.Wypadkowa.Prac;
            sumaZdrowPrac += element.Podatki.Zdrowotna.Prac;
    
            sumaEmerFirma += element.Podatki.Emerytalna.Firma;
            sumaRentFirma += element.Podatki.Rentowa.Firma;
            sumaChorFirma += element.Podatki.Chorobowa.Firma;
            sumaWypadFirma += element.Podatki.Wypadkowa.Firma;
            sumaZdrowFirma += element.Podatki.Zdrowotna.Firma;
    
            sumaFP += element.Podatki.FP.Skladka;
            sumaFGSP += element.Podatki.FGSP.Skladka;
            sumaFEP += element.Podatki.FEP.Skladka;
    
            sumaZaliczka += element.Podatki.ZalFIS;
            sumaKoszty += element.Podatki.KosztyPIT;
            sumaUlga += element.Podatki.Ulga;
        }
        
        colNieOpodatSum.EditValue = sumaNieOpodat;
        colOpodatSum.EditValue = sumaOpodat;
    
        colZUS.AddLine("{0:n} E", emerP);
        colZUS.AddLine("{0:n} R", rentP);
        colZUS.AddLine("{0:n} C", chorP);
        if (wypadP!=0)
            colZUS.AddLine("{0:n} W", wypadP);
        colZUSSum.EditValue = emerP+rentP+chorP+wypadP;
    
        colZUSFirmy.AddLine("{0:n} E", emerF);
        colZUSFirmy.AddLine("{0:n} R", rentF);
        if (chorF!=0)
            colZUSFirmy.AddLine("{0:n} C", chorF);
        colZUSFirmy.AddLine("{0:n} W", wypadF);
        if (srpars.Fundusze) {
            colZUSFirmy.AddLine("{0:n} F", fp);
            colZUSFirmy.AddLine("{0:n} G", fgsp);
            colZUSFirmy.AddLine("{0:n} P", fep);
        }
        colZUSFirmySum.EditValue = emerF + rentF + chorF + wypadF + (srpars.Fundusze ? fp + fgsp + fep : 0m);
    
        colPodatki.AddLine("{0:n} &nbsp;&nbsp;", fis);
        colPodatki.AddLine("{0:n} Z", zdrow);
        colPodatki.AddLine("{0:n} K", koszty);
        colPodatki.AddLine("{0:n} U", ulga);
        colPodatkiSum.EditValue = fis+zdrow;
    
        Currency ror = wypłata.Inne;
        colPodpis.AddLine(wypłata.Wartosc-ror);
        colPodpis.AddLine(ror);
        colPodpis.AddLine("");
        if (srpars.Fundusze && chorF!=0)
               colPodpis.AddLine("");
        colPodpis.AddLine("<center>.........................<br>(podpis)</center>");
    
        sumaGotowka += wypłata.Wartosc-ror;
        sumaROR += ror;
    
        wyplata += wypłata.Wartosc;
    }

    string GetStanowisko(PracHistoria ph) {
        string stanowiskoPelne = "";
        if (srpars.PelneStanowisko)
            stanowiskoPelne = ph.Etat.StanowiskoPełne;
        if (stanowiskoPelne.Length == 0)
            stanowiskoPelne = ph.Etat.Stanowisko;
        return stanowiskoPelne;
    }
        
    private void Grid_AfterRender(object sender, System.EventArgs e) {
        cellBrutto.EditValue = brutto;
        cellNetto.EditValue = wyplata;
    
        labelEmerPrac.EditValue = sumaEmerPrac;
        labelRentPrac.EditValue = sumaRentPrac;
        labelChorPrac.EditValue = sumaChorPrac;
        labelWypadPrac.EditValue = sumaWypadPrac;
        labelZdrowPrac.EditValue = sumaZdrowPrac;
        labelEmerFirma.EditValue = sumaEmerFirma;
        labelRentFirma.EditValue = sumaRentFirma;
        labelChorFirma.EditValue = sumaChorFirma;
        labelWypadFirma.EditValue = sumaWypadFirma;
        labelZdrowFirma.EditValue = sumaZdrowFirma;
        labelFP.EditValue = sumaFP;
        labelFGSP.EditValue = sumaFGSP;
        labelFEP.EditValue = sumaFEP;
        labelZaliczka.EditValue = sumaZaliczka;
        labelKoszty.EditValue = sumaKoszty;
        labelUlga.EditValue = sumaUlga;
        labelGotowka.EditValue = sumaGotowka.Value;
        labelROR.EditValue = sumaROR.Value;
        labelRazem.EditValue = sumaROR.Value + sumaGotowka.Value;
        
        labelPrac.EditValue = sumaEmerPrac + sumaRentPrac + sumaChorPrac + sumaWypadPrac;
        labelFirma.EditValue = sumaEmerFirma + sumaRentFirma + sumaChorFirma + sumaWypadFirma + sumaFP + sumaFGSP + sumaFEP;
    
        ArrayList arr = new ArrayList(elements.Values);
        arr.Sort();
        Grid2.DataSource = arr;
        Grid2.RowTypeName = typeof(Elem).AssemblyQualifiedName;
    }
    
    RodzajFiltra filtr;
    [Context(Required=true)]
    public Params Parametry {
        set {
            if (value.Paski)
                Grid.ShowHeader = ShowHeader.EveryRow;
    
            if (!value.Sumy) {
                colOkres.Visible = false;
                colElementySum.Visible = false;
                colOpodatSum.Visible = false;
                colNieOpodatSum.Visible = false;
                colZUSSum.Visible = false;
                colZUSFirmySum.Visible = false;
                colPodatkiSum.Visible = false;
                colPodpis.RowSpan = 1;
                Grid.RowsInRow = 1;
            }

            filtr = value.Filtr;
        }
    }

    bool Pasuje(Wyplata w, bool stnKadrowe) {
        int stopien = 0;
        if (stnKadrowe) {
            PracHistoria ph = w.Pracownik[w.ListaPlac.Okres.To];
            stopien = (int)ph.StopienNiepelnosp.Stopien;
        }
        else {
            Wyplata.ZUSInfoWorker zusinfo = new Wyplata.ZUSInfoWorker();
            zusinfo.Wypłata = w;
            stopien = (int)zusinfo.TytułUbezpieczenia.StNiepełnosprawności;
        }        
        switch (filtr) {
            case RodzajFiltra.Wszyscy:
                return true;
            case RodzajFiltra.WszyscyNiepełnosprawni:
                return stopien != 0;
            default:
                return stopien == (int)filtr;
        }
    }
    
    void dc_ContextLoad(Object sender, EventArgs e) {
		Row[] rows = (Row[])dc[typeof(Row[])];
		ArrayList wypłaty = new ArrayList();
		bool bufor = false;
		string listy = "";
		foreach (ListaPlac lista in rows) {
			bufor |= lista.Bufor;
			foreach (Wyplata w in lista.Wyplaty)
				if (Pasuje(w, srpars.StnKadrowe))
					wypłaty.Add(w);
			if (listy!="")
				listy += "; ";
			listy += "<b>" + lista.Numer.NumerPelny + "</b>";
		}
				
        if (bufor)
            ReportHeader1["BUFOR"] = "Lista nie została zatwierdzona!|";
        else
            ReportHeader1["BUFOR"] = "";

        ReportHeader1["STN"] = filtr.ToString();

        if (maxOpisLen!=0 && listy.Length>maxOpisLen)
            listy = listy.Substring(0, maxOpisLen-3) + "...";
            
        Opis.EditValue = "<font size=\"2\">Listy płac: " + listy + "</font>";
        wypłaty.Sort();
        Grid.DataSource = wypłaty;
            
        if (srpars.HideOperator)
			stOperator.SubtitleType = SubtitleType.Empty;
    }
    
    static void Msg(object value) {
    }

		</script>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		<meta content="Microsoft Visual Studio 7.0" name="GENERATOR">
		<meta content="C#" name="CODE_LANGUAGE">
		<meta content="JavaScript" name="vs_defaultClientScript">
		<meta content="http://schemas.microsoft.com/intellisense/ie5" name="vs_targetSchema">
	</HEAD>
	<body>
		<font face="Tahoma">
			<form id="PełnaListaPłac" method="post" runat="server">
				<P>
					<ea:datacontext id="dc" runat="server" OnContextLoad="dc_ContextLoad" LeftMargin="-1" RightMargin="-1"></ea:datacontext><cc1:reportheader NagłówekOddziału="NagłówekOddziału" id="ReportHeader1" title="Lista płac wg stopni niepełnosprawności|%BUFOR%</strong>Stopień niepełnosprawności: <strong>%STN%|</strong>Typ: <strong>{0}|</strong>Okres: <strong>{1}"
						runat="server" DataMember0="ListyPlacViewInfo+Params.Typ" DataMember1="ListyPlacViewInfo+Params.Okres"></cc1:reportheader>
					<ea:DataLabel id="Opis" runat="server" Bold="False"></ea:DataLabel><ea:grid id="Grid" runat="server" DataMember="Wyplaty" RowTypeName="Soneta.Place.WyplataEtat, Soneta.KadryPlace"
						RowsInRow="2" onbeforerow="Grid_BeforeRow" onafterrender="Grid_AfterRender">
						<Columns>
							<ea:GridColumn Width="4" BottomBorder="Single" Align="Right" DataMember="#" Caption="Lp"
								ID="colLP"></ea:GridColumn>
							<ea:GridColumn ColSpan="2" Format="Za: {0}" ID="colOkres" NoWrap="True"></ea:GridColumn>
							<ea:GridColumn Width="26" BottomBorder="Single" Caption="Nazwisko i imię" ID="colNazImie" VAlign="Middle"></ea:GridColumn>
							<ea:GridColumn Width="26" BottomBorder="Single" Caption="Elementy płacy" ID="colElementy" NoWrap="True"
								VAlign="Top"></ea:GridColumn>
							<ea:GridColumn Align="Center" Format="Suma:" ID="colElementySum"></ea:GridColumn>
							<ea:GridColumn BottomBorder="Single" Align="Right" Caption="Elementy~opodatkowane" ID="colOpodat"
								VAlign="Top"></ea:GridColumn>
							<ea:GridColumn Align="Right" Format="{0:n}" ID="colOpodatSum"></ea:GridColumn>
							<ea:GridColumn BottomBorder="Single" Align="Right" Caption="Elementy~nieopodatk." ID="colNieOpodat"
								VAlign="Top"></ea:GridColumn>
							<ea:GridColumn Align="Right" Format="{0:n}" ID="colNieOpodatSum"></ea:GridColumn>
							<ea:GridColumn BottomBorder="Single" Align="Right" Caption="Składki ZUS~pracownika" ID="colZUS"
								VAlign="Top"></ea:GridColumn>
							<ea:GridColumn Align="Right" Format="{0:n}" ID="colZUSSum"></ea:GridColumn>
							<ea:GridColumn BottomBorder="Single" Align="Right" Caption="Składki ZUS~pracodawcy" ID="colZUSFirmy"
								VAlign="Top"></ea:GridColumn>
							<ea:GridColumn Align="Right" Format="{0:n}" ID="colZUSFirmySum"></ea:GridColumn>
							<ea:GridColumn BottomBorder="Single" Align="Right" Caption="Zal.US/Zdrow.|Koszty/Ulga" ID="colPodatki"
								VAlign="Top"></ea:GridColumn>
							<ea:GridColumn Align="Right" Format="{0:n} N" ID="colPodatkiSum"></ea:GridColumn>
							<ea:GridColumn Align="Right" Caption="Got&#243;wka|ROR" ID="colPodpis" RowSpan="2" VAlign="Top"></ea:GridColumn>
						</Columns>
					</ea:grid><ea:sectionmarker id="SectionMarker2" runat="server"></ea:sectionmarker><font face="Tahoma" size="2"><STRONG>Podsumowanie:</STRONG></font>
				</P>
				<table id="Table4" style="FONT-SIZE: 8pt; FONT-FAMILY: Tahoma; BORDER-COLLAPSE: collapse"
					borderColor="silver" width="60%" border="1">
					<tbody>
						<tr>
							<td align="center" width="20%">Składka</td>
							<td align="center" width="20%">Składki pracownika</td>
							<td align="center" width="20%">Składki pracodawcy</td>
							<td align="center" width="20%"></td>
							<td align="center" width="20%"></td>
						</tr>
						<tr>
							<td>Emerytalna:</td>
							<td align="right"><ea:datalabel id="labelEmerPrac" runat="server" Format="{0:n}"></ea:datalabel></td>
							<td align="right"><ea:datalabel id="labelEmerFirma" runat="server" Format="{0:n}"></ea:datalabel></td>
							<td>Zaliczka podatku:</td>
							<td align="right"><ea:datalabel id="labelZaliczka" runat="server" Format="{0:n}"></ea:datalabel></td>
						</tr>
						<tr>
							<td>Rentowa:</td>
							<td align="right"><ea:datalabel id="labelRentPrac" runat="server" Format="{0:n}"></ea:datalabel></td>
							<td align="right"><ea:datalabel id="labelRentFirma" runat="server" Format="{0:n}"></ea:datalabel></td>
							<td>Koszty uzyskania:</td>
							<td align="right"><ea:datalabel id="labelKoszty" runat="server" Format="{0:n}"></ea:datalabel></td>
						</tr>
						<tr>
							<td>Chorobowa:</td>
							<td align="right"><ea:datalabel id="labelChorPrac" runat="server" Format="{0:n}"></ea:datalabel></td>
							<td align="right"><ea:datalabel id="labelChorFirma" runat="server" Format="{0:n}"></ea:datalabel></td>
							<td>Ulga podatkowa:</td>
							<td align="right"><ea:datalabel id="labelUlga" runat="server" Format="{0:n}"></ea:datalabel></td>
						</tr>
						<tr>
							<td>Wypadkowa:</td>
							<td align="right"><ea:datalabel id="labelWypadPrac" runat="server" Format="{0:n}"></ea:datalabel></td>
							<td align="right"><ea:datalabel id="labelWypadFirma" runat="server" Format="{0:n}"></ea:datalabel></td>
							<td><strong>Gotówka:</strong></td>
							<td align="right"><ea:datalabel id="labelGotowka" runat="server" Format="{0:n}"></ea:datalabel></td>
						</tr>
						<tr>
							<td>FP:</td>
							<td></td>
							<td align="right"><ea:datalabel id="labelFP" runat="server" Format="{0:n}"></ea:datalabel></td>
							<td><strong>ROR:</strong></td>
							<td align="right"><ea:datalabel id="labelROR" runat="server" Format="{0:n}"></ea:datalabel></td>
						</tr>
						<tr>
							<td>FGŚP:</td>
							<td></td>
							<td align="right"><ea:datalabel id="labelFGSP" runat="server" Format="{0:n}"></ea:datalabel></td>
							<td><STRONG>Razem:</STRONG></td>
							<td align="right"><ea:datalabel id="labelRazem" runat="server" Format="{0:n}"></ea:datalabel></td>
						</tr>
						<tr>
							<td>FEP:</td>
							<td align="right">&nbsp;</td>
							<td align="right">
		<font face="Tahoma">
			                    <ea:datalabel id="labelFEP" runat="server" Format="{0:n}"></ea:datalabel>
		</font>
	                        </td>
							<td>&nbsp;</td>
							<td>&nbsp;</td>
						</tr>
						<tr>
							<td><strong>Razem składki:</strong></td>
							<td align="right"><ea:datalabel id="labelPrac" runat="server" Format="{0:n}"></ea:datalabel></td>
							<td align="right"><ea:datalabel id="labelFirma" runat="server" Format="{0:n}"></ea:datalabel></td>
							<td></td>
							<td></td>
						</tr>
						<tr>
							<td>Zdrowotna:</td>
							<td align="right"><ea:datalabel id="labelZdrowPrac" runat="server" Format="{0:n}"></ea:datalabel></td>
							<td align="right"><ea:datalabel id="labelZdrowFirma" runat="server" Format="{0:n}"></ea:datalabel></td>
							<td></td>
							<td></td>
						</tr>
					</tbody>
				</table>
				<ea:sectionmarker id="SectionMarker1" runat="server"></ea:sectionmarker><font face="Tahoma" size="2"><STRONG>Zestawienie 
						elementów:</STRONG></font>
				<br>
				<ea:grid id="Grid2" runat="server">
					<Columns>
						<ea:GridColumn Width="4" Align="Right" DataMember="#" Caption="Lp" ID="col2LP"></ea:GridColumn>
						<ea:GridColumn Width="30" DataMember="Name" Total="Info" Caption="Nazwa" ID="col2Name"></ea:GridColumn>
						<ea:GridColumn Width="10" Align="Right" DataMember="Counter" Total="Sum" Caption="Liczba" ID="col2Counter"></ea:GridColumn>
						<ea:GridColumn Width="12" Align="Right" DataMember="Dodatki" Total="Sum" Format="{0:n}" ID="col2Dodatki"></ea:GridColumn>
						<ea:GridColumn Width="12" Align="Right" DataMember="Potrącenia" Total="Sum" Format="{0:n}" ID="col2Potr"></ea:GridColumn>
						<ea:GridColumn Width="12" Align="Right" DataMember="Razem" Total="Sum" Format="{0:n}" ID="col2Razem"></ea:GridColumn>
					</Columns>
				</ea:grid>
				<cc1:reportfooter id="ReportFooter1" runat="server">
					<Cells>
						<cc1:FooterCell Caption="Opodatkowane (brutto):" Format1="{0:u}," ID="cellBrutto"></cc1:FooterCell>
						<cc1:FooterCell Caption="Do wypłaty (netto):" Format1="{0:u}," ID="cellNetto"></cc1:FooterCell>
					</Cells>
					<Subtitles>
						<cc1:FooterSubtitle Caption="Sprawdzono pod względem merytorycznym" SubtitleType="DataPodpis" Width="50"></cc1:FooterSubtitle>
						<cc1:FooterSubtitle Caption="Sprawdzono pod względem formalno prawnym" SubtitleType="DataPodpis" Width="50"></cc1:FooterSubtitle>
						<cc1:FooterSubtitle ID="stOperator" SubtitleType="Operator"></cc1:FooterSubtitle>
						<cc1:FooterSubtitle Caption="data"></cc1:FooterSubtitle>
						<cc1:FooterSubtitle Caption="gł&#243;wny księgowy"></cc1:FooterSubtitle>
						<cc1:FooterSubtitle Caption="kierownik jednostki"></cc1:FooterSubtitle>
					</Subtitles>
				</cc1:reportfooter></form>
		</font>
	</body>
</HTML>

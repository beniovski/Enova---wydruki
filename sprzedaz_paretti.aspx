<%@ Import Namespace="System.Diagnostics" %>
<%@ Import Namespace="Soneta.Types" %>
<%@ Import Namespace="Soneta.Waluty" %>
<%@ Import Namespace="Soneta.Kasa" %>
<%@ Import Namespace="Soneta.Handel" %>
<%@ Import Namespace="Soneta.Business.App" %>
<%@ Import Namespace="Soneta.Business.Db" %>
<%@ Import Namespace="Soneta.Business" %>
<%@ Import Namespace="Soneta.Core" %>
<%@ Register TagPrefix="cc1" Namespace="Soneta.Core.Web" Assembly="Soneta.Core.Web" %>
<%@ Register TagPrefix="ea" Namespace="Soneta.Web" Assembly="Soneta.Web" %>

<%@ Page Language="c#" CodePage="1200" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" >
<html xmlns="http://www.w3.org/1999/xhtml">
<head>

    <title>Sprzedaż</title>
    <script runat="server">

        ParametryWydrukuDokumentu parametry;
        [Context]
        public ParametryWydrukuDokumentu Parametry {
            get { return parametry; }
            set { parametry = value; }
        }

        private bool SprawdźPłatności( DokumentHandlowy dokument ) {
            bool result = false;
            foreach( Platnosc platnosc in dokument.Platnosci ) {
                if( platnosc.Kwota.Symbol.Equals( "PLN" ) ) {
                    result = true;
                }
            }
            return result;
        }

        private bool SprawdźSwift( DokumentHandlowy dokument ) {
            bool warunek1 = dokument.DaneKontrahenta == null || dokument.RachunekBankowy == null || dokument.RachunekBankowy.Rachunek == null || dokument.RachunekBankowy.Rachunek.SWIFT == "";
            bool warunek2 = false;
            if( dokument.Kontrahent != null && dokument.Kontrahent.RodzajPodmiotu == RodzajPodmiotu.Krajowy )
                warunek2 = dokument.RachunekBankowy != null && dokument.RachunekBankowy.Waluta.Symbol.Equals( "PLN" ) && SprawdźPłatności( dokument );

            return ( warunek1 || warunek2 );
        }

        private bool SprawdźSwift2( DokumentHandlowy dokument ) {
            bool warunek1 = dokument.DaneKontrahenta == null || dokument.RachunekBankowy2 == null || dokument.RachunekBankowy2.Rachunek == null || dokument.RachunekBankowy2.Rachunek.SWIFT == "";
            bool warunek2 = false;
            if( !warunek1 && dokument.Kontrahent != null && dokument.Kontrahent.RodzajPodmiotu == RodzajPodmiotu.Krajowy )
                warunek2 = dokument.RachunekBankowy2 != null && dokument.RachunekBankowy2.Waluta.Symbol.Equals( "PLN" ) && SprawdźPłatności( dokument );

            return ( warunek1 && warunek2 );
        }

        void OnContextLoad(Object sender, EventArgs args) {
            DataRepeater1.DataSource = (IEnumerable)Parametry;
            DokumentHandlowy dokument = Parametry.Dokument;

            NipSection.Visible = dokument.DaneKontrahenta.StatusPodmiotu != StatusPodmiotu.Finalny && !String.IsNullOrEmpty( dokument.DaneKontrahenta.EuVAT );

            IPieczątkaFirmy pieczątka = ReportHeader.GetPieczątka( dc, null, false);
            var nazwas = pieczątka.NazwaFormatowana;
            var adres1s = pieczątka.Adres.Linia1;
            var adres2s = pieczątka.Adres.Linia2;
            var nips = dokument.Kontrahent.RodzajPodmiotu == RodzajPodmiotu.Krajowy ? pieczątka.NIP : pieczątka.EuVAT.Replace("-", String.Empty);

            if(dokument.Wydruk.JestJednostkaNadrzedna) {

                var jednostkaNadrzedna = CoreModule.GetInstance(dokument).Config.JednostkaNadrzedna;

                NazwaFirmyS.EditValue = jednostkaNadrzedna.Dane.Nazwa;
                AdresFirmySLinia1.EditValue = jednostkaNadrzedna.Adres.Linia1;
                AdresFirmySLinia2.EditValue = jednostkaNadrzedna.Adres.Linia2;
                var nipw = dokument.Kontrahent.RodzajPodmiotu == RodzajPodmiotu.Krajowy ? jednostkaNadrzedna.Dane.NIP : jednostkaNadrzedna.Dane.EuVAT.Replace("-", String.Empty);
                NipFirmyS.EditValue = nipw;

                NazwaFirmyW.EditValue = nazwas;
                AdresFirmyWLinia1.EditValue = adres1s;
                AdresFirmyWLinia2.EditValue = adres2s;
                NipFirmyW.EditValue = nips;
            }
            else {
                FirmaWystawca.Visible = false;

                NazwaFirmyS.EditValue = nazwas;
                AdresFirmySLinia1.EditValue = adres1s;
                AdresFirmySLinia2.EditValue = adres2s;
                NipFirmyS.EditValue = nips;
            }


            dc.AdditionalFooterInfo = dokument.Definicja.InformacjeKRS;

            if (dokument.RachunekBankowy==null
                || dokument.RachunekBankowy.Rachunek == null
                || dokument.RachunekBankowy.Rachunek.Bank==null) {
                labelBank.Visible = false;
            }

            if( !dokument.Definicja.DrukujSWIFTZawsze ) {
                if( SprawdźSwift( dokument ) )
                    labelSwift.Visible = false;
            }

            if (dokument.RachunekBankowy2 == null
                || dokument.RachunekBankowy2.Rachunek == null
                || dokument.RachunekBankowy2.Rachunek.Bank == null)
                labelBank2.Visible = false;

            if( SprawdźSwift2( dokument ) )
                labelSwift2.Visible = false;

            if( dokument.JestDokZaliczkowy() ) {
                sectionDoZaplaty.Visible = false;
            }

            //Tylko tyle zostało z kodu liczącego płatności.
            platnik.Visible = dokument.InnyPłatnik;

            sww.Visible = dokument.JestSWW;

            if(dokument.Definicja.KodKreskowyZNumeremDok != KodKreskowyZNumeremDok.Brak)
            {
                DataLabel15.WithBarcode = true;
                DataLabel15.BarcodeFontSize = 100;
                DataLabel15.BarcodeFontType = (SKKFontType) dokument.Definicja.KodKreskowyZNumeremDok;
                DataLabel15.BarcodeMethodGeneration = BarcodeGenerator.ZXing;
            }
            RodzajKorektyCol.Visible = dokument.DokumentKorygowany != null;

            //Ukrywamy tabelkę VAT i kolumny VAT dla dokumentów nie VAT
            //Dostosowujemy nazwy kolumn
            string nazwa;
            if (dokument.Definicja.SumyVAT!=SposobLiczeniaSumVAT.NieLiczyć)
                nazwa = "faktury";
            else {
                SectionVAT.Visible = false;
                vat.Visible = false;
                nazwa = "rachunku";
            }

            // Ukrywamy kolumne kwoty VAT, jesli dokument nie jest zaliczkowy.
            bool jestMniejszaKwota = dokument.LiczonaOd == SposobLiczeniaVAT.OdNetto ?
                dokument.SumaPozycji.Netto != dokument.Suma.Netto :
                dokument.SumaPozycji.Brutto != dokument.Suma.Brutto;
            bool jestVatZaliczk =
                (dokument.Definicja.EdycjaWartosci == EdycjaWartosciDokumentu.PozwalajNaMniejsząKwotę) &&
                (dokument.Wydruk.JestSumaPozycji /*&& jestMniejszaKwota*/); // <-- TID: 13891;
            bool nowyObieg;
            bool końcowy = dokument.JestKoncowy(out nowyObieg);
            SectionVATZamowienia.Visible = końcowy;
            SectionVATZaliczkowego.Visible = jestVatZaliczk && !dokument.Korekta;
            SectionKorektaZaliczki.Visible = jestVatZaliczk && dokument.Korekta;

            // TID: 13891;
            if (jestVatZaliczk && !jestMniejszaKwota)
                SectionVAT.Visible = false;

            if (dokument.Wydruk.NabywcaPodatnik == 1)
                SectionVAT.Visible = false;

            Grid1_VAT.Visible = false;
            SectionWartBZamowienia.Visible = !SectionVATZaliczkowego.Visible && !końcowy && jestMniejszaKwota;
            TabelaVatZaliczkiNapis.Visible = jestVatZaliczk && !końcowy;
            TabelaVatKoncowegoNapis.Visible = false;
            DataLabelDopłataZaliczki.EditValue = "Podlega opodatkowaniu";

            //Jeżeli dokumenty liczone od brutto, to wymieniamy nagłówki
            if (dokument.OdBrutto)
                wartosc.Caption = "Wartość brutto";

            //Formatujemy podpisy
            stPodpis.Caption = "<font size=1>Osoba upoważniona do wystawienia faktury VAT </font><br><font size=2>"+dokument.Wydruk.UprawnionyDoWystawienia.FullName+"</font><br><br>";
            stOsoba.Caption = "Faktura bez podpisu odbiorcy";

            // Ukrywanie kolumn z ceną przed rabatem i rabatem procentowym
            Grid1_RabatP.Visible = Grid1_CenaPrzedRabatem.Visible = dokument.JestRabat && Parametry.Rabat
                && !dokument.Definicja.CenaWartosc0;

            Grid1_CenaNettoPoRabacie.Visible = !dokument.OdBrutto;
            Grid1_CenaBruttoPoRabacie.Visible = dokument.OdBrutto;

            if (dokument.ID < 0 || dokument.State == RowState.Modified)
                DataLabelOstrzezenie.EditValue = "Zmiany na dokumencie nie zostały zatwierdzone";

            // TID: 14694; 9.1; TID: 16316; 9.3;
            bool szVisible = dokument.DokumentyZaliczkowe.Length > 0;
            if (szVisible && dokument.Korekta && dokument.DokumentKorygowany != null)
            {
                szVisible = dokument.DokumentKorygowanyPierwszy.JestDokZaliczkowy();
            }
            sectionZaliczki.Visible = szVisible;


            if (dokument.Wydruk.JestUproszczony) // ukrywam kolumny, nie patrząc na ich wcześniejszy stan ... 
            {
                Grid_SumyVat_NettoCy.Visible = false;
                Grid_VATZamowienia_NettoCy.Visible = false;
                Grid_VATZaliczkowego_NettoCy.Visible = false;

                Pozycje_Ilosc.Visible = false;
                Pozycje_IloscSym.Visible = false;

                Grid1_CenaNettoPoRabacie.Visible = false;
                Grid1_CenaBruttoPoRabacie.Visible = false;
                wartosc.Visible = false;

                Grid1_VAT.Visible = false;
                vat.Visible = false;
                sww.Visible = false;
            }

            if(String.IsNullOrWhiteSpace(dokument.Wydruk.Procedura))
                dlProcedura.Visible = false;

            if (dokument.JestKorektaRabatowa)
            {
                KorektaRabatowaInfo.EditValue = String.Format("Rabat za okres: {0}-{1}", dokument.Okres.From, dokument.Okres.To);

                Pozycje_Ilosc.Visible = false;
                Pozycje_IloscSym.Visible = false;
                Grid1_CenaPrzedRabatem.Visible = false;
                Grid1_RabatP.Visible = false;
                Grid1_CenaNettoPoRabacie.Visible = false;
                Grid1_CenaBruttoPoRabacie.Visible = false;
                RodzajKorektyCol.Visible = false;
            }

            lDataEtykieta.Visible = lData.Visible = dokument.Wydruk.DatyDokumentu.IsVisibleData;
            lDataDostawyEtykieta.Visible = lDataDostawy.Visible = dokument.Wydruk.DatyDokumentu.IsVisibleDataDostawy;
            lDataOperacjiEtykieta.Visible = lDataOperacji.Visible = dokument.Wydruk.DatyDokumentu.IsVisibleDataOperacji;
            lDataOtrzymaniaEtykieta.Visible = lDataOtrzymania.Visible = dokument.Wydruk.DatyDokumentu.IsVisibleDataOtrzymania;

            if (dokument.Definicja.DrukowanieZestawieniaMagazynowych)
                Grid_Magazynowe.DataSource = dokument.Wydruk.DokumentyPowiazane(dokument, false, true, TypRelacjiHandlowej.HandlowoMagazynowa);
        }

        void DataRepeater1_BeforeRow(Object sender, EventArgs args) {
            KopiaDokumentu kopia = (KopiaDokumentu)DataRepeater1.CurrentRow;
            DokumentHandlowy dokument = kopia.Dokument;

            // TID: 13434;14320; 
            // string td1 = dokument.Definicja.IsParagon ? "Paragon {0}" : "Faktura {0}"; // tid: 15125; w przypadku ff nie jest to prawda ... 
            string td1 = dokument.Definicja.TytulWydruku + " {0}";

            string td2 = kopia.KopiaCaption;
            string title = "<table style=\"font-size: 9pt; width: 100%; margin: 0px; padding: 0px;  \"><tr><td align=\"left\"><b>"+td1+"</b></td><td width=\"100px\" align=\"right\">"+td2+"</td></tr></table>";
            ReportHeader.Title = title;


            if(dokument.Kategoria == KategoriaHandlowa.Sprzedaż || dokument.Kategoria == KategoriaHandlowa.KorektaSprzedaży) {
                lKopiaCaption.Visible = true;
                if (kopia.Kopia==TypKopiiDokumentu.Duplikat || kopia.Kopia==TypKopiiDokumentu.OryginałDuplikat || kopia.Kopia==TypKopiiDokumentu.KopiaDuplikat)
                    lDataDuplikatuEtykieta.Visible = lDataDuplikatu.Visible = true;
            }

            string nazwa;
            if (dokument.Definicja.SumyVAT!=SposobLiczeniaSumVAT.NieLiczyć)
                nazwa = "faktury";
            else
                nazwa = "rachunku";
            if(kopia.Kopia == TypKopiiDokumentu.OryginałDuplikat || kopia.Kopia == TypKopiiDokumentu.KopiaDuplikat || kopia.Kopia == TypKopiiDokumentu.Duplikat)
                stPodpis.Caption = "<font size=1>Osoba upoważniona do wystawienia faktury VAT </font><br><font size=2>"+dokument.Session.Login.Operator.FullName+"</font><br><br>";
        }

        void niezapłacone_BeforeRow(Object sender, RowEventArgs args) {
            WydrukDokumentu.NiezapłaconeInfo p = (WydrukDokumentu.NiezapłaconeInfo)args.Row;
            // Mateusz - task 10271
            if( p.Płatność.SposobZaplaty.Typ != TypySposobowZaplaty.Przelew
                || ( p.Płatność.SposobZaplaty.Typ == TypySposobowZaplaty.Przelew && p.Płatność.EwidencjaSP.Rachunek.Numer == (p.Płatność.Dokument as DokumentHandlowy).RachunekBankowy.Rachunek.Numer
                && (p.Płatność.Dokument as DokumentHandlowy).Wydruk.Niezapłacone.Count == 1 ) ) { // dla całej reszty zostawiamy jak leci
                SposobZaplaty.EditValue = p.Płatność.SposobZaplaty;
            }
            else  { // a dla przelewu doklejamy numer rachunku
                SposobZaplaty.AddLine( p.Płatność.SposobZaplaty + " na rachunek bankowy" );
                SposobZaplaty.AddLine( p.Płatność.EwidencjaSP.Rachunek.Numer );
            }

            if ((p.Płatność.Dokument as DokumentHandlowy).InnyPłatnik) {
                platnik.AddLine(p.Płatność.Podmiot.Nazwa);
                platnik.AddLine(p.Płatność.Podmiot.Adres);
                platnik.AddLine("NIP: " + p.Płatność.Podmiot.EuVAT);
            }
        }
        void gridZaliczki_BeforeRow(object sender, RowEventArgs args)
        {
            DokumentHandlowy z = (DokumentHandlowy)args.Row;
            DokumentHandlowy d = (DokumentHandlowy)this.dc.Context[typeof(DokumentHandlowy)];
            SubTable st = d.ZaliczkiRelacje;
            if (st.IsEmpty
                && z.SposobPrzenoszeniaZaliczki == SposobPrzenoszeniaZaliczki.NieDotyczy)
            {
                this.colZaliczka.EditValue = z.BruttoCy;
            }
            else
            {
                Currency v = new Currency(decimal.Zero, z.BruttoCy.Symbol);
                foreach (RelacjaHandlowa.Zaliczka rz in st)
                {
                    if (rz.Nadrzedny == z)
                    {
                        v += rz.Wartosc;
                    }
                }
                this.colZaliczka.EditValue = v;
            }
        }

        void gridMagazynowe_BeforeRow(object sender, RowEventArgs args)
        {
            var han = (DokumentHandlowy)dc.Context[typeof(DokumentHandlowy)];
            var mag = (DokumentHandlowy)args.Row;
            MagWartCol.EditValue = han.OdBrutto ? mag.Suma.BruttoCy : mag.Suma.NettoCy;
        }







        
</script>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta content="Microsoft Visual Studio 7.0" name="GENERATOR" />
    <meta content="C#" name="CODE_LANGUAGE" />
    <meta content="JavaScript" name="vs_defaultClientScript" />
    <meta content="http://schemas.microsoft.com/intellisense/ie5" name="vs_targetSchema" />
</head>
<body>
    <form id="Sprzedaż" method="post" runat="server">

        <ea:datacontext id="dc" runat="server" typename="Soneta.Handel.DokumentHandlowy,Soneta.Handel"
            oncontextload="OnContextLoad" rightmargin="-1" leftmargin="-1"></ea:datacontext>

        <ea:datarepeater id="DataRepeater1" runat="server" onbeforerow="DataRepeater1_BeforeRow"
            rowtypename="Soneta.Handel.KopiaDokumentu,Soneta.Handel" width="100%" height="161px">
            
            <ea:SectionMarker ID="SectionMarker9" runat="server">
            </ea:SectionMarker>

            <ea:PageBreak ID="PageBreak1" runat="server" BreakFirstTimes="False" ResetPageCounter="True" BreakDocument="True">
            </ea:PageBreak>

            
            <cc1:reportheader id="ReportHeader" 
                runat="server" DataMember0="Dokument.Numer" FirstHeader="False"></cc1:reportheader>

            <div style="width: 100%;">
                <table id="Table4" style="font-size: 10px; font-family: Tahoma" width="100%">
                    <tr>
                        <td style="font-weight: bold; font-size: 18px;" valign="top" align="left">

                           

                            <img alt="" align="left" hspace="20" src="http://www.paretti.pl/images/logo150.png" style="height: 80x; width: 80px; text-align: right" />

                           

                            <ea:DataLabel ID="DataLabel19" runat="server" DataMember="Dokument.Definicja.TytulWydruku">
                            </ea:DataLabel>
                            <ea:DataLabel ID="DataLabel20" runat="server" DataMember="Dokument.Wydruk.MalyPodatnik_Do_20130101">
                                <ValuesMap>
                                    <ea:ValuesPair Key="False" Value=" " />
                                    <ea:ValuesPair Key="True" Value=" MP " />
                                </ValuesMap>
                            </ea:DataLabel>
                            nr
                            <ea:DataLabel ID="DataLabel15" runat="server" DataMember="Dokument.Numer" WithBarcode="False">
                            </ea:DataLabel>
                            <ea:DataLabel ID="dlProcedura" runat="server" DataMember="Dokument.Wydruk.Procedura" Format="&lt;br /&gt;&lt;span style='font-size: 13px;'&gt;{0}&lt;/span&gt;">
                            </ea:DataLabel>
                            <ea:DataLabel ID="DataLabel14" runat="server" DataMember="Dokument.Wydruk.MalyPodatnik_Od_20130101">
                                <ValuesMap>
                                    <ea:ValuesPair Key="False" Value="" />
                                    <ea:ValuesPair Key="True" Value="&lt;br /&gt;&lt;span style='font-size: 13px;'&gt;metoda kasowa&lt;/span&gt;" />
                                </ValuesMap>
                            </ea:DataLabel>
                            <ea:DataLabel ID="DataLabel4" runat="server" DataMember="Dokument.Stan">
                                <ValuesMap>
                                    <ea:ValuesPair Key="Anulowany" Value="&lt;br&gt;Dokument został anulowany" />
                                    <ea:ValuesPair Key="Bufor" Value="&lt;br&gt;Dokument nie został zatwierdzony" />
                                    <ea:ValuesPair Key="Zablokowany" Value="" />
                                    <ea:ValuesPair Key="Zatwierdzony" Value="" />
                                </ValuesMap>
                            </ea:DataLabel>
                            <br />
                            <ea:DataLabel ID="DataLabelOstrzezenie" runat="server">
                            </ea:DataLabel>
                            <br/>
                            <span style="font-weight: normal; font-size: 13px;">
                                <ea:DataLabel ID="lKopiaCaption" runat="server" DataMember="KopiaCaption" Bold="False" Visible="False"></ea:DataLabel>
                            <br />
                            <br />
                            </span>
                        </td>
                        <td valign="top" align="right">
                            <ea:DataLabel ID="lDataEtykieta" runat="server" DataMember="Dokument.Wydruk.DatyDokumentu.DataEtykieta" Bold="False" EncodeHTML="True"></ea:DataLabel> 
                            <br/>
                            <ea:DataLabel ID="lDataDostawyEtykieta" runat="server" DataMember="Dokument.Wydruk.DatyDokumentu.DataDostawyEtykieta" Bold="False" EncodeHTML="True"></ea:DataLabel>
                            <br/>
                            <ea:DataLabel ID="lDataOperacjiEtykieta" runat="server" DataMember="Dokument.Wydruk.DatyDokumentu.DataOperacjiEtykieta" Bold="False" EncodeHTML="True"></ea:DataLabel>
                            <br/>
                            <ea:DataLabel ID="lDataOtrzymaniaEtykieta" runat="server" DataMember="Dokument.Wydruk.DatyDokumentu.DataOtrzymaniaEtykieta" Bold="False" EncodeHTML="True"></ea:DataLabel>
                            <br/>
                            <ea:DataLabel ID="lDataDuplikatuEtykieta" runat="server" DataMember="Dokument.Wydruk.DatyDokumentu.DataDuplikatuEtykieta" Bold="False" EncodeHTML="True" Visible="False"></ea:DataLabel>
                        </td>
                        <td width="10">
                        </td>
                        <td valign="top" align="right">
                            <ea:DataLabel ID="lData" runat="server" DataMember="Dokument.Wydruk.DatyDokumentu.Data" EncodeHTML="True"> </ea:DataLabel>
                            <br/>
                            <ea:DataLabel ID="lDataDostawy" runat="server" DataMember="Dokument.Wydruk.DatyDokumentu.DataDostawy" EncodeHTML="True"> </ea:DataLabel>
                            <br/>
                            <ea:DataLabel ID="lDataOperacji" runat="server" DataMember="Dokument.Wydruk.DatyDokumentu.DataOperacji" EncodeHTML="True"> </ea:DataLabel>
                            <br/>
                            <ea:DataLabel ID="lDataOtrzymania" runat="server" DataMember="Dokument.Wydruk.DatyDokumentu.DataOtrzymania" EncodeHTML="True"> </ea:DataLabel>
                            <br/>
                            <ea:DataLabel ID="lDataDuplikatu" runat="server" DataMember="Dokument.Wydruk.DatyDokumentu.DataDuplikatu" EncodeHTML="True" Visible="False"> </ea:DataLabel>
                            <br />
                        </td>
                    </tr>
                </table>
            </div>
            <table id="Table1" width="100%">
                <tr>
                    <td valign="top" colspan="2">
                        <ea:Section ID="Section4" runat="server" Width="100%" DataMember="Dokument.DokumentKorygowany"
                            ConditionValue="IS NOT NULL">
                            <em style="text-decoration: underline;">Dokument korygowany:</em>
                            <div style="font-size: 13px; left: 10px; font-family: Tahoma; position: relative">
                                <ea:DataLabel ID="DataLabel23" runat="server" DataMember="Dokument.DokumentKorygowanyPierwszy.Numer" EncodeHTML="True"> </ea:DataLabel>
                                <br/>
                                <ea:DataLabel ID="lDataKorygowanegoEtykieta" runat="server" DataMember="Dokument.Wydruk.DatyDokumentuKorygowanegoPierwszego.DataEtykieta" Bold="False" EncodeHTML="True"> </ea:DataLabel>
                                <ea:DataLabel ID="lDataKorygowanego" runat="server" DataMember="Dokument.Wydruk.DatyDokumentuKorygowanegoPierwszego.Data" EncodeHTML="True"> </ea:DataLabel>
                                <br/>
                                <ea:DataLabel ID="lDataOperacjiKorygowanegoEtykieta" runat="server" DataMember="Dokument.Wydruk.DatyDokumentuKorygowanegoPierwszego.DataOperacjiEtykieta" Bold="False" EncodeHTML="True"> </ea:DataLabel>
                                <ea:DataLabel ID="lDataOperacjiKorygowanego" runat="server" DataMember="Dokument.Wydruk.DatyDokumentuKorygowanegoPierwszego.DataOperacji" EncodeHTML="True"> </ea:DataLabel>
                                <br />
                            </div>
                        </ea:Section>
                    </td>
                </tr>
                <tr>
                    <td valign="top" width="50%">

                        <ea:Section ID="FirmaSprzedawca" runat="server"> 
                            <em style="text-decoration: underline;">Sprzedawca:</em>
                            <div style="font-size: 13px; left: 10px; font-family: Tahoma; position: relative">
                                <ea:DataLabel ID="NazwaFirmyS" runat="server" EncodeHTML="True" />
                                <br/>
                                <ea:DataLabel ID="AdresFirmySLinia1" runat="server" Bold="False" EncodeHTML="True" />
                                <br/>
                                <ea:DataLabel ID="AdresFirmySLinia2" runat="server" Bold="False" EncodeHTML="True" />
                                <br/>
                                NIP: <ea:DataLabel ID="NipFirmyS" runat="server" Bold="False" EncodeHTML="True" />
                            </div>
                        </ea:Section>
                        
                        <ea:Section ID="FirmaWystawca" runat="server">
                            <em style="text-decoration: underline;">Wystawca:</em>
                            <div style="font-size: 13px; left: 10px; font-family: Tahoma; position: relative">
                                <ea:DataLabel ID="NazwaFirmyW" runat="server" EncodeHTML="True" />
                                <br/>
                                <ea:DataLabel ID="AdresFirmyWLinia1" runat="server" Bold="False" EncodeHTML="True" />
                                <br/>
                                <ea:DataLabel ID="AdresFirmyWLinia2" runat="server" Bold="False" EncodeHTML="True" />
                                <br/>
                                NIP: <ea:DataLabel ID="NipFirmyW" runat="server" Bold="False" EncodeHTML="True" />
                            </div>
                        </ea:Section>

                        <!-- Oddział firmy -->
                        <ea:Section ID="OddzialFirmy" runat="server" DataMember="Dokument.Wydruk.JestOddzial">
                            <em style="text-decoration: underline;">Oddział:</em>
                            <div style="font-size: 13px; left: 10px; font-family: Tahoma; position: relative;">
                                <ea:DataLabel ID="DataLabel42" runat="server" EncodeHTML="True" DataMember="Dokument.Wydruk.PieczatkaOddziału.Nazwa" ></ea:DataLabel> <br />
                                <ea:DataLabel ID="DataLabel44" runat="server" EncodeHTML="True" Bold="false" DataMember="Dokument.Wydruk.PieczatkaOddziału.Adres.Linia1" ></ea:DataLabel> <br />
                                <ea:DataLabel ID="DataLabel45" runat="server" EncodeHTML="True" Bold="false" DataMember="Dokument.Wydruk.PieczatkaOddziału.Adres.Linia2" ></ea:DataLabel>
                            </div>
                        </ea:Section>

                        <!-- Oddział firmy -->
                        
                        <ea:Section ID="sectionBank" runat="server" DataMember="Dokument.IsRachunekBankowy">
                            <em style="text-decoration: underline;">Konto bankowe:</em>
                        </ea:Section>
                        <div style="font-size: 13px; left: 10px; font-family: Tahoma; position: relative">
                            <ea:DataLabel ID="labelBank" runat="server" DataMember="Dokument.RachunekBankowy.Rachunek.Bank.Nazwa"
                                Bold="False" Format="{0}<br>">
                            </ea:DataLabel>
                            <ea:DataLabel ID="labelSwift" runat="server" DataMember="Dokument.RachunekBankowy.Rachunek.SWIFT"
                                Bold="False" Format="SWIFT: {0}<br>">
                            </ea:DataLabel>
                            <ea:DataLabel ID="DataLabel12" runat="server" DataMember="Dokument.NumerRachunkuBankowego"
                                Bold="False">
                            </ea:DataLabel>
                        </div>
                        <ea:Section ID="DrugiRachunekSection" runat="server" DataMember="Dokument.IsRachunekBankowy2">
                        <em style="text-decoration: underline;">Drugie konto bankowe:</em>
                        <div style="font-size: 13px; left: 10px; font-family: Tahoma; position: relative">
                            <ea:DataLabel ID="labelBank2" runat="server" DataMember="Dokument.RachunekBankowy2.Rachunek.Bank.Nazwa"
                                Bold="False" Format="{0}<br>">
                            </ea:DataLabel>
                            <ea:DataLabel ID="labelSwift2" runat="server" DataMember="Dokument.RachunekBankowy2.Rachunek.SWIFT"
                                Bold="False" Format="SWIFT: {0}<br>">
                            </ea:DataLabel>
                            <ea:DataLabel ID="DataLabel51" runat="server" DataMember="Dokument.RachunekBankowy2.Rachunek.Numer"
                                Bold="False">
                            </ea:DataLabel>
                        </div>
                        </ea:Section>
                    </td>
                    <td valign="top">
                        <em style="text-decoration: underline;">Nabywca:</em>
                        <div style="font-size: 13px; left: 10px; font-family: Tahoma; position: relative">                            
                            <ea:Section ID="NabywcaDaneSection" runat="server" DataMember="Dokument.Wydruk.NieJestUproszczony">
                            <ea:DataLabel ID="DataLabel1" runat="server" DataMember="Dokument.DaneKontrahenta.NazwaFormatowana" EncodeHTML="True">
                            </ea:DataLabel>
                            <br/>
                            <ea:DataLabel ID="DataLabel2" runat="server" DataMember="Dokument.DaneKontrahenta.Adres.Linia1"
                                Bold="False" EncodeHTML="True">
                            </ea:DataLabel>
                            <br/>
                            <ea:DataLabel ID="DataLabel3" runat="server" DataMember="Dokument.DaneKontrahenta.Adres.Linia2"
                                Bold="False" EncodeHTML="True">
                            </ea:DataLabel>
                            <br/>
                            </ea:Section>
                            <ea:Section ID="NipSection" runat="server" >
                              NIP:
                              <ea:DataLabel ID="DataLabel11" runat="server" DataMember="Dokument.DaneKontrahenta.EuVAT"
                                  Bold="False" EncodeHTML="True">
                              </ea:DataLabel>
                            </ea:Section>
                        </div>
                        <ea:Section ID="sectionOdbiorca" runat="server" DataMember="Dokument.Wydruk.JestOdbiorca">
                            <em style="text-decoration: underline;">Odbiorca:</em>
                            <div style="font-size: 13px; left: 10px; font-family: Tahoma; position: relative">
                                <ea:DataLabel ID="DataLabel10" runat="server" DataMember="Dokument.DaneOdbiorcy.NazwaFormatowana" EncodeHTML="True">
                                </ea:DataLabel>
                                <br/>
                                <ea:DataLabel ID="DataLabel9" runat="server" DataMember="Dokument.DaneOdbiorcy.Adres.Linia1"
                                    Bold="False" EncodeHTML="True">
                                </ea:DataLabel>
                                <br/>
                                <ea:DataLabel ID="DataLabel8" runat="server" DataMember="Dokument.DaneOdbiorcy.Adres.Linia2"
                                    Bold="False" EncodeHTML="True">
                                </ea:DataLabel>
                                <br/>                             
                                NIP:
                                <ea:DataLabel ID="DataLabel7" runat="server" DataMember="Dokument.DaneOdbiorcy.EuVAT" Bold="False" EncodeHTML="True">
                                </ea:DataLabel>                                
                            </div>
                        </ea:Section>
                    </td>
                </tr>
            </table>
            <ea:Section ID="KursSection" runat="server" Width="100%" DataMember="Dokument.Wydruk.JestWaluta">
                <font size="2">Kurs <strong>1 </strong>
                    <ea:DataLabel ID="DataLabel31" runat="server" DataMember="Dokument.BruttoCy.Symbol" EncodeHTML="True">
                    </ea:DataLabel>
                    &nbsp;=
                    <ea:DataLabel ID="KursWaluty" runat="server" DataMember="Dokument.KursWaluty" EncodeHTML="True">
                    </ea:DataLabel>
                    <strong>&nbsp;PLN</strong> z dnia
                    <ea:DataLabel ID="DataLabel32" runat="server" DataMember="Dokument.DataOgłoszeniaKursu" EncodeHTML="True">
                    </ea:DataLabel>
                    &nbsp;(<ea:DataLabel ID="DataLabel33" runat="server" DataMember="Dokument.TabelaKursowa" EncodeHTML="True">
                    </ea:DataLabel>
                    )</font></ea:Section>
            <ea:Section ID="KorektaKursuSection" runat="server" Width="100%" DataMember="Dokument.Wydruk.JestKorektaKursu">
                Korekta kursu:
                <div style="font-size: 13px">
                     Kurs przed korektą: <strong>1</strong> <ea:DataLabel ID="DataLabel53" runat="server" DataMember="Dokument.DokumentKorygowany.BruttoCy.Symbol" EncodeHTML="True" />
                     &nbsp;=&nbsp;<ea:DataLabel ID="DataLabel54" runat="server" DataMember="Dokument.DokumentKorygowany.KursWaluty" EncodeHTML="True" /><strong>&nbsp;PLN</strong> z dnia
                     <ea:DataLabel ID="DataLabel55" runat="server" DataMember="Dokument.DokumentKorygowany.DataOgłoszeniaKursu" EncodeHTML="True" />
                     &nbsp;(<ea:DataLabel ID="DataLabel56" runat="server" DataMember="Dokument.DokumentKorygowany.TabelaKursowa" EncodeHTML="True" />)
                     <br />
                     Kurs po korekcie: <strong>1</strong> <ea:DataLabel ID="DataLabel46" runat="server" DataMember="Dokument.BruttoCy.Symbol" EncodeHTML="True" />
                     &nbsp;=&nbsp;<ea:DataLabel ID="DataLabel49" runat="server" DataMember="Dokument.KursWaluty" EncodeHTML="True" /><strong>&nbsp;PLN</strong> z dnia
                     <ea:DataLabel ID="DataLabel52" runat="server" DataMember="Dokument.DataOgłoszeniaKursu" EncodeHTML="True" />
                     &nbsp;(<ea:DataLabel ID="DataLabel57" runat="server" DataMember="Dokument.TabelaKursowa" EncodeHTML="True" />)</div>
            </ea:Section>
            <FONT face="Arial" size="2"><ea:DataLabel ID="KorektaRabatowaInfo" runat="server" Bold="True" ></ea:DataLabel></FONT>
            <ea:Grid ID="Grid1" runat="server" RowTypeName="Soneta.Handel.PozycjaDokHandlowego,Soneta.Handel"
                DataMember="Dokument.Wydruk.PozycjeRazem" RowsInRow="2" GroupData0="Workers.WydrukPozycji.SekcjaDokumentu"
                GroupLine="{0}">
                <Columns>
                    <ea:GridColumn Width="4" Align="Right" DataMember="Lp" Caption="Lp." RowSpan="2" runat="server"> </ea:GridColumn>
                    <ea:GridColumn DataMember="NazwaPierwszaLinia" Caption="Nazwa towaru/usługi" runat="server" EncodeHTML="True"> </ea:GridColumn>
                    <ea:GridColumn DataMember="NazwaResztaLinii" Caption=" " runat="server"> </ea:GridColumn>
                    <ea:GridColumn ID="Pozycje_Ilosc" Width="9" RightBorder="None" Align="Right" DataMember="Ilosc.Value" Caption="Ilość" RowSpan="2" runat="server"> </ea:GridColumn>
                    <ea:GridColumn ID="Pozycje_IloscSym" Width="5" DataMember="Ilosc.Symbol" Caption="jm." RowSpan="2" runat="server"> </ea:GridColumn>

                    <ea:GridColumn ID="Grid1_CenaPrzedRabatem" runat="server"  DataMember="Cena" Width="15" RowSpan="2" Caption="Cena przed rabatem" Align="Right"> </ea:GridColumn>
                    <ea:GridColumn ID="Grid1_RabatP" runat="server"  DataMember="Rabat" Width="10" RowSpan="2" Caption="Rabat %" Align="Right"> </ea:GridColumn>
                    <ea:GridColumn ID="Grid1_CenaNettoPoRabacie" Width="14" Align="Right" DataMember="CenaNettoPoRabacie" Caption="Cena netto" RowSpan="2" runat="server"> </ea:GridColumn>
                    <ea:GridColumn ID="Grid1_CenaBruttoPoRabacie" Width="15" Align="Right" DataMember="CenaBruttoPoRabacie" Caption="Cena brutto" RowSpan="2" runat="server"> </ea:GridColumn>
                    
                    <ea:GridColumn Width="15" Align="Right" DataMember="WartoscCy" Caption="Wartość netto" Format="&lt;b&gt;{0}&lt;/b&gt;" ID="wartosc" RowSpan="2" runat="server"> </ea:GridColumn>
                    <ea:GridColumn Width="7" Align="Right" DataMember="DefinicjaStawki" Caption="Stawka|VAT" ID="vat" RowSpan="2" runat="server"> </ea:GridColumn>
            <ea:GridColumn Width="15" Align="Right" DataMember="Suma.VAT" Caption="Kwota VAT" ID="Grid1_VAT" RowSpan="2" runat="server"> </ea:GridColumn>
                    <ea:GridColumn Width="12" DataMember="SWW" Caption="PKWiU" ID="sww" RowSpan="2" runat="server"> </ea:GridColumn>
                    <ea:GridColumn runat="server" ID="RodzajKorektyCol" DataMember="RodzajKorektyOpis" Width="16" Caption="Zmiana|(Przyczyna korekty)" RowSpan="2" Align="Center"> </ea:GridColumn>
                </Columns>
            </ea:Grid>
            
            <!-- etykieta: Korekta zaliczki -->
            <ea:Section ID="SectionKorektaZaliczki" runat="server" Width="100%" Visible="false">
            <table id="Table5" cellspacing="0" cellpadding="0" width="90%" border="0">
                <tr><td>&nbsp;</td></tr>
                <tr>
                    <td style="width: 151px" align="right">&nbsp;</td>
                    <td style="width: 145px; border-top: black 1px solid" valign="bottom" align="left">&nbsp;</td>
                    <td style="font-weight: bold; font-size: 18px; border-top: black 1px solid; height: 22px" 
                        valign="bottom" align="right">Korekta zaliczki:
                    </td>
                </tr>
            </table>			
            </ea:Section>
            <!-- etykieta: Korekta zaliczki -->
            
            <ea:Section ID="SectionVATZamowienia" runat="server" Width="100%">
                <table cellpadding="0" cellspacing="0" border="0" width="100%">
                    <tr align="right">
                        <td width="100%" style="font-size: 13px; text-align:right; vertical-align:bottom;">
                            <ea:Section runat="server" id="SectionVATZamowieniaNapis">
                                <em>Wartość zamówienia:</em>&nbsp;
                            </ea:Section>
                        </td>                    
                        <td align="right">
                            <ea:Grid ID="Grid_VATZamowienia" runat="server" RowTypeName="Soneta.Handel.DokumentZaliczkowy.SumaVATAdapter,Soneta.Handel"
                                DataMember="Workers.DokumentZaliczkowy.TabelaVAT" WithSections="False">
                                <Columns>
                                    <ea:GridColumn Width="15" Align="Right" DataMember="DefinicjaStawki" Total="Info"
                                        Caption="Stawka VAT" runat="server">
                                    </ea:GridColumn>
                                    <ea:GridColumn Width="17" Align="Right" DataMember="Suma.NettoCy" Total="Sum" Caption="Netto"
                                        runat="server" ID="Grid_VATZamowienia_NettoCy">
                                    </ea:GridColumn>
                                    <ea:GridColumn Width="17" Align="Right" DataMember="Suma.VATCy" Total="Sum" Caption="Kwota VAT"
                                        Format="{0:n}" runat="server">
                                    </ea:GridColumn>
                                    <ea:GridColumn Width="17" Align="Right" DataMember="Suma.BruttoCy" Total="Sum" Caption="Brutto"
                                        runat="server">
                                    </ea:GridColumn>
                                </Columns>
                            </ea:Grid>
                        </td>
                    </tr>
                </table>
                <table id="Table6" cellspacing="0" cellpadding="0" width="90%">
                    <tr>
                        <td style="width: 151px" align="right" width="151">
                        </td>
                        <td style="width: 195px; border-bottom: black 1px solid" valign="bottom" align="left"
                            width="145" colspan="1" rowspan="1">
                            <ea:DataLabel ID="DataLabelDopłataZaliczki" runat="server" Bold="False" Format="{0}:"></ea:DataLabel>
                        </td>
                        <td style="font-weight: bold; font-size: 18px; border-bottom: black 1px solid;
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               height: 22px" valign="bottom" align="right">
                            <ea:DataLabel ID="DataLabel47" runat="server" DataMember="Dokument.BruttoCy" Bold="False">
                            </ea:DataLabel>
                        </td>
                    </tr>
                    <tr>
                        <td style="width: 151px" align="right">
                        </td>
                        <td style="width: 145px" align="left">
                            <font size="2"><em>Słownie:</em></font></td>
                        <td align="right">
                            <font size="2"><em>
                                <ea:DataLabel ID="DataLabel48" runat="server" DataMember="Dokument.BruttoCy" Bold="False"
                                    Format="{0:+t}">
                                </ea:DataLabel>
                            </em></font>
                        </td>
                    </tr>
                </table>                
            </ea:Section>
            
            <ea:Section ID="SectionVATZaliczkowego" runat="server" Width="100%">
                <table cellpadding="0" cellspacing="0" border="0">
                    <tr>
                        <td width="100%" style="font-size: 13px; text-align:right; vertical-align:bottom;">
                            <em>Wartość zamówienia:</em>&nbsp;
                        </td>
                        <td align="right">
                            <ea:Grid ID="Grid_VATZaliczkowego" runat="server" RowTypeName="Soneta.Handel.DokumentZaliczkowy.SumaVATAdapter,Soneta.Handel"
                                DataMember="Workers.DokumentZaliczkowy.TabelaVAT"  WithSections="False">
                                <Columns>
                                    <ea:GridColumn Width="15" Align="Right" DataMember="DefinicjaStawki" Total="Info"
                                        Caption="Stawka VAT" runat="server">
                                    </ea:GridColumn>
                                    <ea:GridColumn Width="17" Align="Right" DataMember="Suma.NettoCy" Total="Sum" Caption="Netto"
                                        runat="server" ID="Grid_VATZaliczkowego_NettoCy">
                                    </ea:GridColumn>
                                    <ea:GridColumn Width="17" Align="Right" DataMember="Suma.VATCy" Total="Sum" Caption="Kwota VAT"
                                        Format="{0:n}" runat="server">
                                    </ea:GridColumn>
                                    <ea:GridColumn Width="17" Align="Right" DataMember="Suma.BruttoCy" Total="Sum" Caption="Brutto"
                                        runat="server">
                                    </ea:GridColumn>
                                </Columns>
                            </ea:Grid>
                        </td>
                    </tr>
                </table>
              <table id="Table2" cellspacing="0" cellpadding="0" width="90%">
                <tr>
                    <td style="width: 151px" align="right" width="151">
                    </td>
                    <td style="width: 145px; border-bottom: black 1px solid" valign="bottom" align="left"
                        width="145" colspan="1" rowspan="1">Kwota zaliczki:</td>
                    <td style="font-weight: bold; font-size: 18px; border-bottom: black 1px solid;
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    height: 22px" valign="bottom" align="right">
                        <ea:DataLabel ID="DataLabel50" runat="server" DataMember="Dokument.BruttoCy" Bold="False">
                        </ea:DataLabel>
                    </td>
                </tr>
                <tr>
                    <td style="width: 151px" align="right">
                    </td>
                    <td style="width: 145px" align="left">
                        <font size="2"><em>Słownie:</em></font></td>
                    <td align="right">
                        <font size="2"><em>
                            <ea:DataLabel ID="DataLabel60" runat="server" DataMember="Dokument.BruttoCy" Bold="False"
                                Format="{0:+t}">
                            </ea:DataLabel>
                        </em></font>
                    </td>
                </tr>
            </table>  
            </ea:Section>            
            <ea:Section ID="SectionVAT" runat="server" Width="100%">
                <table cellpadding="0" cellspacing="0" border="0">
                    <tr>
                        <td width="25%" style="font-size: 10px;">
                            <ea:DataLabel ID="DataLabel24" runat="server" DataMember="Dokument.Wydruk.InfoKorekty1"
                                Bold="False" EncodeHTML="True">
                            </ea:DataLabel>
                            <br />
                            <ea:DataLabel ID="DataLabel41" runat="server" DataMember="Dokument.Wydruk.InfoKorekty2"
                                Bold="False" EncodeHTML="True">
                            </ea:DataLabel>
                        </td>
                        <td width="100%" style="font-size: 13px; text-align:right; vertical-align:bottom;">
                            <ea:Section runat="server" id="TabelaVatZaliczkiNapis">
                                <em>Tabela VAT zaliczki:</em>&nbsp;
                            </ea:Section>                        
                            <ea:Section runat="server" id="TabelaVatKoncowegoNapis">
                                <em>Tabela VAT dopłaty do zaliczki:</em>&nbsp;
                            </ea:Section>
                        </td>                        
                        <td align="right">
                            <ea:Grid ID="Grid_SumyVat" runat="server" RowTypeName="Soneta.Handel.SumaVAT,Soneta.Handel"
                                DataMember="Dokument.SumyVAT" WithSections="False">
                                <Columns>
                                    <ea:GridColumn Width="15" Align="Right" DataMember="DefinicjaStawki" Total="Info"
                                        Caption="Stawka VAT" runat="server">
                                    </ea:GridColumn>
                                    <ea:GridColumn ID="Grid_SumyVat_NettoCy" Width="17" Align="Right" DataMember="Suma.NettoCy" Total="Sum" Caption="Netto"
                                        runat="server">
                                    </ea:GridColumn>
                                    <ea:GridColumn Width="17" Align="Right" DataMember="Suma.VATCy" Total="Sum" Caption="Kwota VAT"
                                        Format="{0:n}" runat="server">
                                    </ea:GridColumn>
                                    <ea:GridColumn Width="17" Align="Right" DataMember="Suma.BruttoCy" Total="Sum" Caption="Brutto"
                                        runat="server">
                                    </ea:GridColumn>
                                </Columns>
                            </ea:Grid>
                        </td>
                    </tr>
                </table>
            </ea:Section>
            <ea:Section ID="SectionWartBZamowienia" runat="server" DataMember="Dokument.Wydruk.JestSumaPozycji"
                Width="100%">
                <em>Wartość&nbsp;brutto zamówienia:</em>
                <ea:DataLabel ID="DataLabel34" runat="server" DataMember="Dokument.SumaPozycji.Brutto" Bold="False" EncodeHTML="True">
                </ea:DataLabel>
                &nbsp;PLN<br/>
            </ea:Section>
            <ea:Section ID="sectionZaliczki" runat="server" DataMember="Dokument.DokumentyZaliczkowe">
                <em>Faktury zaliczkowe:<br/>
                </em>
                <ea:Grid ID="gridZaliczki" runat="server" RowTypeName="Soneta.Handel.DokumentHandlowy,Soneta.Handel"
                    DataMember="Dokument.Wydruk.DokumentyZaliczkowe" WithSections="False" OnBeforeRow="gridZaliczki_BeforeRow">
                    <Columns>
                        <ea:GridColumn runat="server" Width="4" Align="Right" DataMember="#" Caption="Lp."> </ea:GridColumn>
                        <ea:GridColumn runat="server" Width="30" DataMember="Numer"> </ea:GridColumn>
                        <ea:GridColumn runat="server" Width="15" Align="Center" DataMember="Data" Total="Info"> </ea:GridColumn>
                        <ea:GridColumn runat="server" Width="18" Align="Right" DataMember="BruttoCy" Total="Sum" Caption="Wartość"> </ea:GridColumn> 
                        <ea:GridColumn runat="server" Width="18" Align="Right" Total="Sum" ID="colZaliczka" Caption="Rozliczona zaliczka"></ea:GridColumn>
                    </Columns>
                </ea:Grid>
                <br/>
            </ea:Section>
            <ea:Section ID="sectionDoZaplaty" runat="server">
            <table id="Table3" cellspacing="0" cellpadding="0" width="90%">
                <tr>
                    <td style="width: 151px" align="right" width="151">
                    </td>
                    <td style="width: 145px; border-bottom: black 1px solid" valign="bottom" align="left"
                        width="145" colspan="1" rowspan="1">
                        <ea:DataLabel ID="doZaplaty" runat="server" DataMember="Dokument.Wydruk.KierunekZapłaty"
                            Bold="False" Format="{0}:">
                        </ea:DataLabel>
                    </td>
                    <td style="font-weight: bold; font-size: 18px; border-bottom: black 1px solid;
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 height: 22px" valign="bottom" align="right">
                        <ea:DataLabel ID="DataLabel5" runat="server" DataMember="Dokument.Wydruk.BruttoCyPlus" Bold="False">
                        </ea:DataLabel>
                    </td>
                </tr>
                <tr>
                    <td style="width: 151px" align="right">
                    </td>
                    <td style="width: 145px" align="left">
                        <font size="2"><em>Słownie:</em></font></td>
                    <td align="right">
                        <font size="2"><em>
                            <ea:DataLabel ID="DataLabel6" runat="server" DataMember="Dokument.BruttoCy" Bold="False"
                                Format="{0:+t}">
                            </ea:DataLabel>
                        </em></font>
                    </td>
                </tr>
            </table>
            </ea:Section>
            <ea:Section ID="sectionWplaty" runat="server" DataMember="Dokument.Zaliczki">
                <em>Rozliczone zaliczki:<br/>
                </em>
                <ea:Grid ID="Grid2" runat="server" RowTypeName="Soneta.Handel.RelacjaZaliczki,Soneta.Handel"
                    DataMember="Dokument.Zaliczki" WithSections="False">
                    <Columns>
                        <ea:GridColumn runat="server" Width="4" Align="Right" DataMember="#" Caption="Lp.">
                        </ea:GridColumn>
                        <ea:GridColumn runat="server" Width="20" DataMember="Zaplata.SposobZaplaty" Caption="Spos&#243;b zapłaty">
                        </ea:GridColumn>
                        <ea:GridColumn runat="server" Width="15" Align="Center" DataMember="Zaplata.DataDokumentu"
                            Caption="Data">
                        </ea:GridColumn>
                        <ea:GridColumn runat="server" Width="20" Align="Right" DataMember="Kwota">
                        </ea:GridColumn>
                        <ea:GridColumn runat="server" Width="25" DataMember="Zaplata.NumerDokumentu" Caption="Numer">
                        </ea:GridColumn>
                    </Columns>
                </ea:Grid>
            </ea:Section>
            <br />
            <ea:Section ID="Section3" runat="server">
                <em>                
                    <ea:DataLabel ID="DataLabel13" runat="server" DataMember="Dokument.Wydruk.ZaplaconoInfo"
                        Bold="False">
                    </ea:DataLabel>                    
                    </em>
            </ea:Section>
            <br />
            <!-- Mateusz - zapłata zaliczkami 100% -->
            <ea:Section runat="server" DataMember="Dokument.Wydruk.ZaliczkaPokrywaCałość">
                <em>
                    Pozostało do zapłaty 0 <%=Parametry.Dokument.BruttoCy.Symbol %>.
                </em>
            </ea:Section>
                        
            <ea:Section ID="sectionNiezaplacone" runat="server" DataMember="Dokument.Wydruk.SąNiezapłacone">
                <div>

                    <em>
                        <ea:DataLabel ID="DataLabel43" runat="server" DataMember="Dokument.Wydruk.KierunekZapłaty" Bold="False" Format="{0}:">
                            <ValuesMap>
                                <ea:ValuesPair Key="Do zapłaty" Value="Pozostało do zapłaty"></ea:ValuesPair>
                                <ea:ValuesPair Key="Do zwrotu" Value="Pozostało do zwrotu"></ea:ValuesPair>
                                <ea:ValuesPair Key="Wartość" Value="Wartość" />
                                <ea:ValuesPair Key="Zapłacona zaliczka" Value="Do zapłaty"></ea:ValuesPair>
                                <ea:ValuesPair Key="Zwr&#243;cona zaliczka" Value="Zwr&#243;cona zaliczka"></ea:ValuesPair>
                            </ValuesMap>
                        </ea:DataLabel>
                      </em>

                    <ea:Grid ID="niezapłacone" runat="server" OnBeforeRow="niezapłacone_BeforeRow" RowTypeName="Soneta.Kasa.Platnosc,Soneta.Kasa"
                        DataMember="Dokument.Wydruk.Niezapłacone" WithSections="True">
                        <Columns>
                            <ea:GridColumn runat="server" Width="4" Align="Right" DataMember="#" Caption="Lp.">
                            </ea:GridColumn>
                            <ea:GridColumn runat="server" Width="40" ID="SposobZaplaty" Caption="Sposób zapłaty">
                            </ea:GridColumn>
                            <ea:GridColumn runat="server" Width="15" Align="Center" DataMember="Płatność.Termin"
                                Caption="Termin">
                            </ea:GridColumn>
                            <ea:GridColumn runat="server" Width="20" Align="Right" DataMember="Kwota">
                            </ea:GridColumn>
                            <ea:GridColumn runat="server" Caption="Płatnik" Format="{0:H}" ID="platnik">
                            </ea:GridColumn>
                        </Columns>
                    </ea:Grid>

                </div>
            </ea:Section>
            <ea:Section ID="sectionNumeryNadrzednych" runat="server" DataMember="Dokument.Wydruk.CzyDrukowacNumeryPowiazanych">
                <em><br />Dokumenty powiązane:</em>
                <div style="font-size: 13px; left: 10px; font-family: Tahoma; position: relative">
                    <ea:DataLabel ID="labelNumeryNadrzednych" runat="server" DataMember="Dokument.Wydruk.NumeryNadrzędneZK" Bold="False"></ea:DataLabel>
                    <ea:DataLabel ID="labelNumeryPodrzednych" runat="server" DataMember="Dokument.Wydruk.NumeryPodrzędneBK" Bold="False"></ea:DataLabel>
                </div>
            </ea:Section>
            <ea:Section runat="server" DataMember="Dokument.Wydruk.CzyDrukowacNumeryKorekt">
                <em><br />Poprzednie korekty:</em>
                <div style="font-size: 13px; left: 10px; font-family: Tahoma; position: relative">
                    <ea:DataLabel runat="server" DataMember="Dokument.Wydruk.NumeryPoprzednichKorekt" Bold="false"></ea:DataLabel>
                </div>
            </ea:Section>
            <ea:Section runat="server" DataMember="Dokument.Definicja.DrukowanieZestawieniaMagazynowych">
                <em><br />Powiązane dokumenty magazynowe:</em>
                <ea:Grid ID="Grid_Magazynowe" runat="server" RowTypeName="Soneta.Handel.DokumentHandlowy,Soneta.Handel" onBeforeRow="gridMagazynowe_BeforeRow">
                    <Columns>
                        <ea:GridColumn id="MagNumerCol" DataMember="Numer.NumerPelny" Caption="Dokument" runat="server" Width="20" Align="Center"></ea:GridColumn>
                        <ea:GridColumn id="MagDataCol" DataMember="Data" Caption="Data wystawienia" runat="server" Width="20" Align="Center"></ea:GridColumn>
                        <ea:GridColumn id="MagDataDostawyCol" DataMember="Dostawa.Termin" Caption="Data dostawy" runat="server" Width="20" Align="Center"></ea:GridColumn>
                        <ea:GridColumn id="MagWartCol" Caption="Wartość" runat="server" Width="20" Align="Center"></ea:GridColumn>
                    </Columns>
                </ea:Grid>
            </ea:Section>
            <p style="font-family: Tahoma, Arial; font-size: 13px;">
                <ea:DataLabel ID="OpisDok" runat="server" DataMember="Dokument.Opis" Bold="False"> </ea:DataLabel>
            </p>
            <p style="font-family: Tahoma, Arial; font-size: 13px;">
                <ea:DataLabel ID="OpisWydruku" runat="server" DataMember="Dokument.Wydruk.OpisWydruku" Bold="False"> </ea:DataLabel>
            </p>
           
            <cc1:ReportFooter ID="Report" runat="server" Height="105px" TheEnd="false">
                <Subtitles>
                   
                    <cc1:FooterSubtitle runat="server" Caption="Operator"  ID="stOsoba" SubtitleType="CenterText" Width="50" >
                    </cc1:FooterSubtitle>
                    <cc1:FooterSubtitle  runat="server" Caption="Osoba" ID="stPodpis" SubtitleType="CenterText" Width="50">
                    </cc1:FooterSubtitle>
                    
                </Subtitles>
            </cc1:ReportFooter>
            
            <ea:SectionMarker ID="SectionMarker8" runat="server" SectionType="Footer"> </ea:SectionMarker>
        </ea:datarepeater>

        <ea:section runat="server" id="SectionRozrachunki" datamember="Wydruk.RozrachunkiKontrahentaVisible">
            <ea:PageBreak runat="server"></ea:PageBreak>
                <em style="font-size: 13px; font-family: Tahoma; ">Wykaz nierozliczonych należności</em>
                <ea:Grid ID="GridRozrachunki" runat="server" DataMember="Wydruk.RozrachunkiKontrahenta">
                    <Columns>
                        <ea:GridColumn runat="server"  Width="4" DataMember="#" Caption="Lp."></ea:GridColumn>
                        <ea:GridColumn runat="server" DataMember="NumerDokumentu" Caption="Numer" Width="20"></ea:GridColumn>
                        <ea:GridColumn runat="server" DataMember="SposobZaplaty.Nazwa" Caption="Forma płatności" Width="15"></ea:GridColumn>
                        <ea:GridColumn runat="server" DataMember="Termin" Caption="Termin" Width="12"></ea:GridColumn>
                        <ea:GridColumn runat="server" DataMember="DoRozliczenia" Caption="Pozostaje" Width="15" Align="Right" Total="Sum"></ea:GridColumn>
                    </Columns>
                </ea:Grid>
        </ea:section>
    </form>
</body>
</html>

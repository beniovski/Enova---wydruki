<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<%@ Page Language="c#" CodePage="1200" %><%@ Register TagPrefix="ea" Namespace="Soneta.Web" Assembly="Soneta.Web" %><%@ Register TagPrefix="cc1" Namespace="Soneta.Core.Web" Assembly="Soneta.Core.Web" %><%@ Import Namespace="Soneta.Core" %><%@ Import Namespace="Soneta.Business" %><%@ Import Namespace="Soneta.Business.App" %><%@ Import Namespace="Soneta.Delegacje" %><%@ Import Namespace="Soneta.Handel" %><%@ Import Namespace="Soneta.Kasa" %><%@ Import Namespace="Soneta.Waluty" %><%@ Import Namespace="Soneta.Types" %><HTML 
xmlns="http://www.w3.org/1999/xhtml"><HEAD><TITLE>Sprzedaż</TITLE>
<META content="text/html; charset=unicode" http-equiv=Content-Type>
<META name=GENERATOR content="Microsoft Visual Studio 7.0">
<META name=CODE_LANGUAGE content=C#>
<META name=vs_defaultClientScript content=JavaScript>
<META name=vs_targetSchema 
content=http://schemas.microsoft.com/intellisense/ie5>
<SCRIPT runat="server">

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

    private DokumentHandlowy dokument;
    void OnContextLoad(Object sender, EventArgs args) {
        DataRepeater1.DataSource = (IEnumerable)Parametry;
        dokument = Parametry.Dokument;

        uwagi.EditValue = dokument.Opis;

        // Task 10623 - 7.8
        dc.AdditionalFooterInfo = dokument.Definicja.InformacjeKRS;

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

        if( !String.IsNullOrEmpty( dokument.Definicja.TytulWydruku2 ) ) {
            SectionTytulWydruku.Visible = false;
            SectionTytulWydruku2.Visible = true;
        } else {
            SectionTytulWydruku.Visible = true;
            SectionTytulWydruku2.Visible = false;
        }

        if( dokument.RachunekBankowy == null
            || dokument.RachunekBankowy.Rachunek == null
            || dokument.RachunekBankowy.Rachunek.Bank == null )
            labelBank.Visible = false;

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

        platnik.Visible = dokument.InnyPłatnik;

        Grid1_RabatP.Visible = Grid1_CenaPrzedRabatem.Visible = dokument.JestRabat && Parametry.Rabat;

        Grid1_CenaNettoPoRabacie.Visible = !dokument.OdBrutto;
        Grid1_CenaBruttoPoRabacie.Visible = dokument.OdBrutto;

        //Wybieramy bloki do wydruku --> inne dla korekty a inne dla sprzedaży
        //i ukrywany nieużywane kolumny
        if (dokument.DokumentKorygowany != null) {
            DataRepeater2.Visible = false;
            DataRepeater3.DataSource = new object[] { dokument };

            rabatprzed.Visible = dokument.JestRabat || dokument.DokumentKorygowany.JestRabat;
            swwprzed.Visible = dokument.JestSWW || dokument.DokumentKorygowany.JestSWW;
            rabatpo.Visible = rabatprzed.Visible;
            swwpo.Visible = swwprzed.Visible;
        }
        else {
            DataRepeater2.DataSource = new object[] { dokument };
            DataRepeater3.Visible = false;

            sww.Visible = dokument.JestSWW;
        }


        if(dokument.Definicja.KodKreskowyZNumeremDok != KodKreskowyZNumeremDok.Brak)
        {
            DataLabel15.WithBarcode = true;
            DataLabel15.BarcodeFontSize = 100;
            DataLabel15.BarcodeFontType = (SKKFontType) dokument.Definicja.KodKreskowyZNumeremDok;
            DataLabel15.BarcodeMethodGeneration = BarcodeGenerator.ZXing;
        }

        colRodzajKorekty.Visible = dokument.DokumentKorygowany != null;

        //Ukrywamy tabelkę VAT i kolumny VAT dla dokumentów nie VAT
        //Dostosowujemy nazwy kolumn
        if (dokument.Definicja.SumyVAT != SposobLiczeniaSumVAT.NieLiczyć)
        {
            DataRepeater4.DataSource = new object[] { dokument };
        }
        else
        {
            DataRepeater4.Visible = false;
            vat.Visible = false;
            vatprzed.Visible = false;
            vatpo.Visible = false;
        }


        // Ukrywamy kolumne kwoty VAT, jesli dokument nie jest zaliczkowy.
        bool jestMniejszaKwota = dokument.LiczonaOd == SposobLiczeniaVAT.OdNetto ?
            dokument.SumaPozycji.Netto != dokument.Suma.Netto :
            dokument.SumaPozycji.Brutto != dokument.Suma.Brutto;
        bool jestVatZaliczk =
            (dokument.Definicja.EdycjaWartosci == EdycjaWartosciDokumentu.PozwalajNaMniejsząKwotę) &&
            (dokument.Wydruk.JestSumaPozycji && jestMniejszaKwota);
        bool nowyObieg;
        bool końcowy = dokument.JestKoncowy(out nowyObieg);
        SectionVATZamowienia.Visible = końcowy;
        SectionVATZaliczkowego.Visible = jestVatZaliczk && !dokument.Korekta;
        SectionKorektaZaliczki.Visible = jestVatZaliczk && dokument.Korekta;
        Grid1_VAT.Visible = false;
        Section4.Visible = !SectionVATZaliczkowego.Visible && !końcowy && jestMniejszaKwota;
        TabelaVatZaliczkiNapis.Visible = jestVatZaliczk && !końcowy;
        TabelaVatKoncowegoNapis.Visible = false;
        DataLabelDopłataZaliczki.EditValue = "Podlega opodatkowaniu / Taxable";

        //Jeżeli dokumenty liczone od brutto, to wymieniamy nagłówki
        if (dokument.OdBrutto) {
            Grid1_CenaPrzedRabatem.Caption = "Cena brutto|<i>Unit Price</i>";
            wartosc.Caption = "Wartość brutto|<i>Value</i>";
            cenaprzed.Caption = "Cena brutto|<i>Unit Price</i>";
            wartoscprzed.Caption = "Wartość brutto|<i>Value</i>";
            cenapo.Caption = "Cena brutto|<i>Unit Price</i>";
        }

        //Formatujemy podpisy
        stOsoba.EditValue = "<font size=2> Osoba upoważniona do systawienia faktury VAT</font>" +
                          "<br><font size = 1><i>Person authorised to issue the invoice</i></font></br><font size=2>"
                          +dokument.Wydruk.UprawnionyDoWystawienia.FullName+"</font>";




        stPodpis.EditValue = "<font size=2>"+"Faktura bez podpisu odbiorcy</font>"+ "<br><font size =1><i>Invoice without recipent's signature</i></font>";

        if (dokument.ID < 0 || dokument.State == RowState.Modified)
            DataLabelOstrzezenie.EditValue = "Zmiany na dokumencie nie zostały zatwierdzone<br />";

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
            Grid1_CenaPrzedRabatem.Visible = false;
            Grid1_CenaNettoPoRabacie.Visible = false;
            Grid1_CenaBruttoPoRabacie.Visible = false;

            wartosc.Visible = false;
            Grid1_VAT.Visible = false;
            vat.Visible = false;
            sww.Visible = false;
        }

        if (dokument.Wydruk.Wystawiony_Do_20130101)
        {
            labelKopiaSlash.EditValue = "/";
        }

        if (String.IsNullOrWhiteSpace(dokument.Wydruk.Procedura))
            dlProcedura.Visible = false;

        lDataEtykieta.Visible = lData.Visible = dokument.Wydruk.DatyDokumentu.IsVisibleData;
        if (lData.Visible)
        {
            lDataEtykieta.EditValue = String.Format("{0}:<br /><em>{1}</em><br />", dokument.Wydruk.DatyDokumentu.DataEtykieta, dokument.Wydruk.DatyDokumentu.DataEtykietaEn);
            lData.EditValue = String.Format("{0}<br /><br />", dokument.Wydruk.DatyDokumentu.Data);
        }

        lDataDostawyEtykieta.Visible = lDataDostawy.Visible = dokument.Wydruk.DatyDokumentu.IsVisibleDataDostawy;
        if (lDataDostawy.Visible)
        {
            lDataDostawyEtykieta.EditValue = String.Format("{0}:<br /><em>{1}</em><br />", dokument.Wydruk.DatyDokumentu.DataDostawyEtykieta, dokument.Wydruk.DatyDokumentu.DataDostawyEtykietaEn);
            lDataDostawy.EditValue = String.Format("{0}<br /><br />", dokument.Wydruk.DatyDokumentu.DataDostawy);
        }

        lDataOperacjiEtykieta.Visible = lDataOperacji.Visible = dokument.Wydruk.DatyDokumentu.IsVisibleDataOperacji;
        if (lDataOperacji.Visible)
        {
            lDataOperacjiEtykieta.EditValue = String.Format("{0}:<br /><em>{1}</em><br />", dokument.Wydruk.DatyDokumentu.DataOperacjiEtykieta, dokument.Wydruk.DatyDokumentu.DataOperacjiEtykietaEn);
            lDataOperacji.EditValue = String.Format("{0}<br /><br />", dokument.Wydruk.DatyDokumentu.DataOperacji);
        }

        lDataOtrzymaniaEtykieta.Visible = lDataOtrzymania.Visible = dokument.Wydruk.DatyDokumentu.IsVisibleDataOtrzymania;
        if (lDataOtrzymania.Visible)
        {
            lDataOtrzymaniaEtykieta.EditValue = String.Format("{0}:<br /><em>{1}</em><br />", dokument.Wydruk.DatyDokumentu.DataOtrzymaniaEtykieta, dokument.Wydruk.DatyDokumentu.DataOtrzymaniaEtykietaEn);
            lDataOtrzymania.EditValue = String.Format("{0}<br /><br />", dokument.Wydruk.DatyDokumentu.DataOtrzymania);
        }
        DataLabel36.Visible = dokument.Zapłata != null;
    }

    void DataRepeater1_BeforeRow(Object sender, EventArgs args) {
        KopiaDokumentu kopia = (KopiaDokumentu)DataRepeater1.CurrentRow;
        DokumentHandlowy dokument = kopia.Dokument;

        // TID: 13434;14320; 
        string td1 = dokument.Definicja.IsParagon ? "Receipt no {0}" : "VAT Invoice no {0}";
        string td2 = String.Format("{0} / <i>{1}</i>", kopia.KopiaCaption, kopia.KopiaCaptionEN);

        string title = "<table style=\"font-size: 9pt; width: 100%; margin: 0px; padding: 0px;  \"><tr><td align=\"left\"><b>" + td1 + "</b></td><td align=\"right\">" + td2 + "</td></tr></table>";
        ReportHeader.Title = title;

        if (kopia.Kopia == TypKopiiDokumentu.Duplikat || kopia.Kopia == TypKopiiDokumentu.OryginałDuplikat || kopia.Kopia == TypKopiiDokumentu.KopiaDuplikat)
        {
            lDataDuplikatu.Visible = lDataDuplikatuEtykieta.Visible = true;
            lDataDuplikatuEtykieta.EditValue = String.Format("{0}:<br /><em>{1}</em><br />", dokument.Wydruk.DatyDokumentu.DataDuplikatuEtykieta, dokument.Wydruk.DatyDokumentu.DataDuplikatuEtykietaEn);
            lDataDuplikatu.EditValue = String.Format("{0}<br /><br />", dokument.Wydruk.DatyDokumentu.DataDuplikatu);
        }

        sectionOdbiorca.Visible = dokument.Wydruk.JestOdbiorca;
    }

    void Grid3_BeforeRow(Object sender, RowEventArgs args) {
        PozycjaDokHandlowego pozycja = (PozycjaDokHandlowego)args.Row;
        if( !pozycja.Dokument.Definicja.DrukujTylkoRoznicePrzedKorekta )
            return;

        args.VisibleRow = pozycja.Korygowana;
    }

    void Grid4_BeforeRow(Object sender, RowEventArgs args) {
        PozycjaDokHandlowego pozycja = (PozycjaDokHandlowego)args.Row;
        if( !pozycja.Dokument.Definicja.DrukujTylkoRoznicePoKorekcie )
            return;

        args.VisibleRow = pozycja.Korygowana;
    }

    void niezapłacone_BeforeRow(Object sender, RowEventArgs args) {
        WydrukDokumentu.NiezapłaconeInfo p = (WydrukDokumentu.NiezapłaconeInfo)args.Row;
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

</SCRIPT>
</HEAD>
<BODY>
<FORM id=Sprzedaż method=post runat="server"><ea:DataContext ID="dc" runat="server" OnContextLoad="OnContextLoad" TypeName="Soneta.Handel.DokumentHandlowy,Soneta.Handel">
        
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </ea:DataContext><ea:DataRepeater ID="DataRepeater1" runat="server" Height="161px" Width="100%" RowTypeName="Soneta.Handel.KopiaDokumentu,Soneta.Handel"
            OnBeforeRow="DataRepeater1_BeforeRow">
            <ea:SectionMarker ID="SectionMarker1" runat="server">
            </ea:SectionMarker>
            <ea:PageBreak ID="PageBreak1" runat="server" BreakFirstTimes="False" ResetPageCounter="True" BreakDocument="True">
            </ea:PageBreak>
           
            <cc1:ReportHeader ID="ReportHeader" runat="server" DataMember0="Dokument.Numer" FirstHeader="False"
                AdditionalPageName=" / <i>page:</i> "  />
            <div style="width: 100%;">
                <table id="Table4" style="font-size: 10px; font-family: Tahoma" width="100%">
                    <tr>
                        <td style="font-weight: bold; font-size: 18px;" valign="top" align="left">
                            <ea:DataLabel ID="DataLabel19" runat="server" DataMember="Dokument.Definicja.TytulWydruku" EncodeHTML="True">
                            </ea:DataLabel>
                            <ea:DataLabel ID="DataLabel20" runat="server" DataMember="Dokument.Wydruk.MalyPodatnik_Do_20130101" EncodeHTML="True">
                                <ValuesMap>
                                    <ea:ValuesPair Key="False" Value=" "></ea:ValuesPair>
                                    <ea:ValuesPair Key="True" Value=" MP "></ea:ValuesPair>
                                </ValuesMap>
                            </ea:DataLabel>
                            nr
                            <ea:DataLabel ID="DataLabel15" runat="server" DataMember="Dokument.Numer" EncodeHTML="True" WithBarcode="False">
                            </ea:DataLabel>
                            <ea:DataLabel ID="DataLabel14" runat="server" DataMember="Dokument.Wydruk.MalyPodatnik_Od_20130101" >
                                <ValuesMap>
                                    <ea:ValuesPair Key="False" Value=""></ea:ValuesPair>
                                    <ea:ValuesPair Key="True" Value="<br /><span style='font-size: 13px;'>metoda kasowa</span>"></ea:ValuesPair>
                                </ValuesMap>
                            </ea:DataLabel>
                              <img alt="" align="left" hspace="20" src="http://www.paretti.pl/images/logo150.png" style="height: 80x; width: 80px; text-align: right" />
                            <ea:DataLabel ID="DataLabel4" runat="server" DataMember="Dokument.Stan" EncodeHTML="False">
                                <ValuesMap>
                                    <ea:ValuesPair Key="Anulowany" Value="&lt;br&gt;Dokument został anulowany"></ea:ValuesPair>
                                    <ea:ValuesPair Key="Bufor" Value="&lt;br&gt;Dokument nie został zatwierdzony"></ea:ValuesPair>
                                    <ea:ValuesPair Key="Zablokowany" Value=""></ea:ValuesPair>
                                    <ea:ValuesPair Key="Zatwierdzony" Value=""></ea:ValuesPair>
                                </ValuesMap>
                            </ea:DataLabel>
                            <br />
                            <ea:DataLabel ID="DataLabelOstrzezenie" runat="server"></ea:DataLabel>                 
                            <em>
                              <ea:Section ID="SectionTytulWydruku" runat="server">
                                <ea:DataLabel ID="DataLabel28" runat="server" DataMember="Dokument.Definicja.TytulWydruku" style="font-size: 24px; " EncodeHTML="True">
                                    <ValuesMap>
                                        <ea:ValuesPair Key="Faktura" Value="Invoice"></ea:ValuesPair>
                                        <ea:ValuesPair Key="Faktura VAT" Value="VAT Invoice"></ea:ValuesPair>
                                        <ea:ValuesPair Key="Faktura VAT dostawy" Value="VAT Invoice"></ea:ValuesPair>
                                        <ea:ValuesPair Key="Paragon" Value="Receipt"></ea:ValuesPair>
                                        <ea:ValuesPair Key="Rachunek" Value="Invoice"></ea:ValuesPair>
                                    </ValuesMap>
                                </ea:DataLabel>
                              </ea:Section>
                              <ea:Section ID="SectionTytulWydruku2" runat="server">
                                <ea:DataLabel runat="server" DataMember="Dokument.Definicja.TytulWydruku2" style="font-size: 24px;" EncodeHTML="True"></ea:DataLabel>
                              </ea:Section>

                                <ea:DataLabel ID="DataLabel27" runat="server" DataMember="Dokument.Wydruk.MalyPodatnik_Do_20130101" EncodeHTML="True">
                                    <ValuesMap>
                                        <ea:ValuesPair Key="False" Value=" "></ea:ValuesPair>
                                        <ea:ValuesPair Key="True" Value=" MP "></ea:ValuesPair>
                                    </ValuesMap>
                                </ea:DataLabel>
                                no
                                <ea:DataLabel ID="DataLabel18" runat="server" DataMember="Dokument.Numer" EncodeHTML="True">
                                </ea:DataLabel>

                            <ea:DataLabel ID="DataLabel13" runat="server" DataMember="Dokument.Wydruk.MalyPodatnik_Od_20130101" >
                                <ValuesMap>
                                    <ea:ValuesPair Key="False" Value=""></ea:ValuesPair>
                                    <ea:ValuesPair Key="True" Value="<br /><span style='font-size: 13px;'>cash VAT accounting</span>"></ea:ValuesPair>
                                </ValuesMap>
                            </ea:DataLabel>

                                <ea:DataLabel ID="dlProcedura" runat="server" DataMember="Dokument.Wydruk.Procedura" Format="<br /><span style='font-size: 13px;'>{0}</span>">
                                </ea:DataLabel>

                                <ea:DataLabel ID="DataLabel42" runat="server" DataMember="Dokument.Stan" EncodeHTML="False">
                                    <ValuesMap>
                                        <ea:ValuesPair Key="Anulowany" Value="&lt;br&gt;Document was made void"></ea:ValuesPair>
                                        <ea:ValuesPair Key="Bufor" Value="&lt;br&gt;Document was not endorsed"></ea:ValuesPair>
                                        <ea:ValuesPair Key="Zablokowany" Value=""></ea:ValuesPair>
                                        <ea:ValuesPair Key="Zatwierdzony" Value=""></ea:ValuesPair>
                                    </ValuesMap>
                                </ea:DataLabel>
                            </em>
                            <br />
                            <span style="font-weight: normal; font-size: 13px;">
                                <ea:DataLabel ID="labelKopia" runat="server" DataMember="KopiaCaption" Bold="False"></ea:DataLabel>
                                <i><ea:DataLabel ID="labelKopiaSlash" runat="server" Bold="False"></ea:DataLabel></i>
                                <i><ea:DataLabel ID="labelKopiaEN" runat="server" DataMember="KopiaCaptionEN" Bold="False"></ea:DataLabel></i>
                            </span>
                        </td>
                        <td valign="top" align="right">
                            <ea:DataLabel ID="lDataEtykieta" runat="server" Bold="False" EncodeHTML="False"></ea:DataLabel> 
                            <ea:DataLabel ID="lDataDostawyEtykieta" runat="server" Bold="False" EncodeHTML="False"></ea:DataLabel>
                            <ea:DataLabel ID="lDataOperacjiEtykieta" runat="server" Bold="False" EncodeHTML="False"></ea:DataLabel>
                            <ea:DataLabel ID="lDataOtrzymaniaEtykieta" runat="server" Bold="False" EncodeHTML="False"></ea:DataLabel>
                            <ea:DataLabel ID="lDataDuplikatuEtykieta" runat="server" Bold="False" EncodeHTML="False" Visible="False"></ea:DataLabel>
                        </td>
                        <td width="10">
                        </td>
                        <td valign="top" align="right">
                            <ea:DataLabel ID="lData" runat="server" EncodeHTML="False"> </ea:DataLabel>
                            <ea:DataLabel ID="lDataDostawy" runat="server" EncodeHTML="False"> </ea:DataLabel>
                            <ea:DataLabel ID="lDataOperacji" runat="server" EncodeHTML="False"> </ea:DataLabel>
                            <ea:DataLabel ID="lDataOtrzymania" runat="server" EncodeHTML="False"> </ea:DataLabel>
                            <ea:DataLabel ID="lDataDuplikatu" runat="server" EncodeHTML="False" Visible="False"> </ea:DataLabel>
                        </td>
                    </tr>
                </table>
            </div>
            <table id="Table1" width="100%">
                <tr>
                    <td valign="top" colspan="2">
                        <ea:Section ID="Section3" runat="server" Width="100%" DataMember="Dokument.DokumentKorygowany"
                            ConditionValue="IS NOT NULL">
                            <u>Dokument korygowany <em>/ Document being corrected:</em></u>&nbsp;
                            <div style="font-size: 13px; left: 10px; font-family: Tahoma; position: relative">
                                <ea:DataLabel ID="Datalabel43" runat="server" DataMember="Dokument.DokumentKorygowanyPierwszy" EncodeHTML="True">
                                </ea:DataLabel>
                                <br>
                                Data wystawienia / <em>Date of issue</em>:<em> </em>
                                <ea:DataLabel ID="Datalabel45x" runat="server" DataMember="Dokument.DokumentKorygowanyPierwszy.Data" EncodeHTML="True">
                                </ea:DataLabel>
                                <br>
                                Data sprzedaży / <em>Date of sale: </em>
                                <ea:DataLabel ID="Datalabel47" runat="server" DataMember="Dokument.DokumentKorygowanyPierwszy.DataOperacji" EncodeHTML="True">
                                </ea:DataLabel>
                            </div>
                        </ea:Section>
                    </td>
                </tr>
                <tr>
                    <td valign="top" width="50%">

                        <ea:Section ID="FirmaSprzedawca" runat="server"> 
                            <u>
                            <br />
                            <br />
                            Sprzedawca <em>/ Seller:</em></u>
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
                            <u>Wystawca <em>/ Issuer:</em></u>
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
                        <ea:Section ID="OddzialFirmy" runat="server" 
                            DataMember="Dokument.Wydruk.JestOddzial">
                            <em style="text-decoration: underline;">Oddział:</em>
                            <div style="font-size: 13px; left: 10px; font-family: Tahoma; position: relative;">
                                <ea:DataLabel ID="DataLabel52" runat="server" EncodeHTML="True" DataMember="Dokument.Wydruk.PieczatkaOddziału.Nazwa" ></ea:DataLabel><br />
                                <ea:DataLabel ID="DataLabel54" runat="server" EncodeHTML="True" Bold="false" DataMember="Dokument.Wydruk.PieczatkaOddziału.Adres.Linia1" ></ea:DataLabel><br />
                                <ea:DataLabel ID="DataLabel45" runat="server" EncodeHTML="True" Bold="false" DataMember="Dokument.Wydruk.PieczatkaOddziału.Adres.Linia2" ></ea:DataLabel>
                            </div>
                        </ea:Section>
                        <!-- Oddział firmy -->
                        
                        <ea:Section ID="sectionBank" runat="server" DataMember="Dokument.IsRachunekBankowy">
                            <u>Konto bankowe <em>/ Bank Account:</em></u>
                        </ea:Section>
                        <div style="font-size: 13px; left: 10px; font-family: Tahoma; position: relative">
                            <ea:DataLabel ID="labelBank" runat="server" DataMember="Dokument.RachunekBankowy.Rachunek.Bank.Nazwa"
                                Bold="False" Format="{0}<br>">
                            </ea:DataLabel>
                            <ea:DataLabel ID="labelSwift" runat="server" DataMember="Dokument.RachunekBankowy.Rachunek.SWIFT"
                                Bold="False" Format="SWIFT: {0}<br>">
                            </ea:DataLabel>
                            <ea:DataLabel ID="DataLabel12" runat="server" DataMember="Dokument.RachunekBankowy.Rachunek.Numer"
                                Bold="False">
                            </ea:DataLabel>
                            <br />
                            <br />
                            <br />
                        </div>
                        <ea:Section ID="DrugiRachunekSection" runat="server" DataMember="Dokument.IsRachunekBankowy2">
                        <u>Drugie konto bankowe <em>/ Second Bank Account:</em></u>
                        <div style="font-size: 13px; left: 10px; font-family: Tahoma; position: relative">
                            <ea:DataLabel ID="labelBank2" runat="server" DataMember="Dokument.RachunekBankowy2.Rachunek.Bank.Nazwa"
                                Bold="False" Format="{0}<br>">
                            </ea:DataLabel>
                            <ea:DataLabel ID="labelSwift2" runat="server" DataMember="Dokument.RachunekBankowy2.Rachunek.SWIFT"
                                Bold="False" Format="SWIFT: {0}<br>">
                            </ea:DataLabel>
                            <ea:DataLabel ID="DataLabel55" runat="server" DataMember="Dokument.RachunekBankowy2.Rachunek.Numer"
                                Bold="False">
                            </ea:DataLabel>
                            <br />
                            <br />
                        </div>
                        </ea:Section>
                    </td>
                    
                    <td valign="top">                    
                        <u>
                        <br />
                        <br />
                        Nabywca <em>/ Buyer:</em></u>
                        <div style="font-size: 13px; left: 10px; font-family: Tahoma; position: relative">
                            <ea:Section ID="NabywcaDaneSection" runat="server" DataMember="Dokument.Wydruk.NieJestUproszczony">
                            <ea:DataLabel ID="DataLabel1" runat="server" DataMember="Dokument.DaneKontrahenta.NazwaFormatowana" EncodeHTML="True">
                            </ea:DataLabel>
                            <br/>
                            <ea:DataLabel ID="DataLabel2" runat="server" DataMember="Dokument.DaneKontrahenta.Adres.Linia1"
                                Bold="False" EncodeHTML="True">
                            </ea:DataLabel>
                            <br />
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
                        <ea:Section ID="sectionOdbiorca" runat="server">
                            <u>Odbiorca <em>/ Receiver:</em></u>
                            <div style="font-size: 13px; left: 10px; font-family: Tahoma; position: relative">
                                <ea:DataLabel ID="DataLabel10" runat="server" DataMember="Dokument.DaneOdbiorcy.NazwaFormatowana" EncodeHTML="True">
                                </ea:DataLabel>
                                <br>
                                <ea:DataLabel ID="DataLabel9" runat="server" DataMember="Dokument.DaneOdbiorcy.Adres.Linia1"
                                    Bold="False" EncodeHTML="True">
                                </ea:DataLabel>
                                <br>
                                <ea:DataLabel ID="DataLabel8" runat="server" DataMember="Dokument.DaneOdbiorcy.Adres.Linia2"
                                    Bold="False" EncodeHTML="True">
                                </ea:DataLabel>
                                <br>
                                NIP:
                                <ea:DataLabel ID="DataLabel7" runat="server" DataMember="Dokument.DaneOdbiorcy.EuVAT"
                                    Bold="False" EncodeHTML="True">
                                </ea:DataLabel>
                            </div>
                        </ea:Section>
                    </td>
                </tr>
            </table>
            <ea:Section ID="KursSection" runat="server" Width="100%" DataMember="Dokument.Wydruk.JestWaluta">
                <font size="2">
                <br />
                <br />
                <br />
                <br />
                Kurs <em>/ Exchange rate </em><strong>1 </strong>
                    <ea:DataLabel ID="DataLabel40" runat="server" DataMember="Dokument.BruttoCy.Symbol" EncodeHTML="True">
                    </ea:DataLabel>
                    &nbsp;=
                    <ea:DataLabel ID="KursWaluty" runat="server" DataMember="Dokument.KursWaluty" EncodeHTML="True">
                    </ea:DataLabel>
                    <strong>&nbsp;PLN</strong> z dnia <em>/ of</em>&nbsp;
                    <ea:DataLabel ID="DataLabel32" runat="server" DataMember="Dokument.DataOgłoszeniaKursu" EncodeHTML="True">
                    </ea:DataLabel>
                    &nbsp;(
                    <ea:DataLabel ID="DataLabel39" runat="server" DataMember="Dokument.TabelaKursowa" EncodeHTML="True">
                    </ea:DataLabel>
                    )</font></ea:Section>
            <ea:DataRepeater ID="DataRepeater2" runat="server" Width="100%">
                <ea:SectionMarker ID="SectionMarker2" runat="server">
                </ea:SectionMarker>
                <ea:Grid ID="Grid1" runat="server" RowTypeName="Soneta.Handel.PozycjaDokHandlowego,Soneta.Handel"
                    DataMember="Pozycje" RowsInRow="2">
                    <Columns>
                        <ea:GridColumn ID="GridColumn1" runat="server" Width="4" Align="Right" DataMember="#" Caption="Lp.|&lt;i&gt;#&lt;/i&gt;" RowSpan="2" EncodeHTML="True"> </ea:GridColumn>
                        <ea:GridColumn ID="GridColumn2" runat="server" DataMember="NazwaPierwszaLinia" Caption="Nazwa towaru/usługi|&lt;i&gt;Product/service name&lt;/i&gt;" EncodeHTML="True"> </ea:GridColumn>
                        <ea:GridColumn ID="GridColumn3" runat="server" DataMember="NazwaResztaLinii" Caption=" "> </ea:GridColumn>
                        <ea:GridColumn ID="Pozycje_Ilosc" runat="server" Width="10" RightBorder="None" Align="Right" DataMember="Ilosc.Value" Caption="Ilość|&lt;i&gt;Quantity&lt;/i&gt;" RowSpan="2" EncodeHTML="True"> </ea:GridColumn>
                        <ea:GridColumn ID="Pozycje_IloscSym" runat="server" Width="5" Align="Center" DataMember="Ilosc.Symbol" Caption="jm.|&lt;i&gt;unit&lt;/i&gt;" RowSpan="2" EncodeHTML="True"> </ea:GridColumn>
                        <ea:GridColumn ID="Grid1_CenaPrzedRabatem" runat="server" Width="15" Align="Right" DataMember="Cena" Caption="Cena netto|&lt;i&gt;Unit price&lt;/i&gt;" RowSpan="2" EncodeHTML="True"> </ea:GridColumn>
                        <ea:GridColumn ID="Grid1_RabatP" runat="server" Width="8" Align="Right" DataMember="Rabat" Caption="Rabat|&lt;i&gt;Discount&lt;/i&gt;" RowSpan="2" EncodeHTML="True"> </ea:GridColumn>
                        <ea:GridColumn ID="Grid1_CenaNettoPoRabacie" Width="14" Align="Right" DataMember="CenaNettoPoRabacie" Caption="Cena netto|&lt;i&gt;NET price&lt;/i&gt;" RowSpan="2" runat="server"> </ea:GridColumn>
                        <ea:GridColumn ID="Grid1_CenaBruttoPoRabacie" Width="15" Align="Right" DataMember="CenaBruttoPoRabacie" Caption="Cena brutto|&lt;i&gt;Gross price&lt;/i&gt;" RowSpan="2" runat="server"> </ea:GridColumn>
                        <ea:GridColumn runat="server" Width="16" Align="Right" DataMember="WartoscCy" Caption="Wartość netto|&lt;i&gt;NET Value&lt;/i&gt;" Format="&lt;b&gt;{0}&lt;/b&gt;" ID="wartosc" RowSpan="2"> </ea:GridColumn>
                        <ea:GridColumn runat="server" Width="10" Align="Right" DataMember="DefinicjaStawki" Caption="Stawka|&lt;i&gt;VAT rate&lt;/i&gt;" ID="vat" RowSpan="2" EncodeHTML="True"> </ea:GridColumn>
                        <ea:GridColumn Width="15" Align="Right" DataMember="Suma.VAT" Caption="Kwota VAT|&lt;i&gt;VAT amount&lt;/i&gt;" ID="Grid1_VAT" RowSpan="2" runat="server"> </ea:GridColumn> 
                        <ea:GridColumn runat="server" Width="15" DataMember="SWW" Caption="PKWiU" ID="sww" RowSpan="2" EncodeHTML="True"> </ea:GridColumn>
                    </Columns>
                </ea:Grid>
                <ea:SectionMarker ID="SectionMarker3" runat="server" SectionType="Footer">
                </ea:SectionMarker>
            </ea:DataRepeater>
            <ea:DataRepeater ID="DataRepeater3" runat="server" Width="100%">
                <ea:SectionMarker ID="SectionMarker4" runat="server">
                </ea:SectionMarker>
                Przed korektą / <em>Before correction:</em>
                <ea:Grid ID="Grid3" runat="server" OnBeforeRow="Grid3_BeforeRow" RowTypeName="Soneta.Handel.PozycjaDokHandlowego,Soneta.Handel"
                    DataMember="Pozycje" RowsInRow="2">
                    <Columns>
                        <ea:GridColumn ID="GridColumn6" runat="server" Width="4" Align="Right" DataMember="#" Caption="Lp.|&lt;i&gt;#&lt;/i&gt;"
                            RowSpan="2" EncodeHTML="True">
                        </ea:GridColumn>
                        <ea:GridColumn ID="GridColumn7" runat="server" DataMember="PozycjaKorygowana.NazwaPierwszaLinia" Caption="Nazwa towaru/usługi|&lt;i&gt;Product/service name&lt;/i&gt;" EncodeHTML="True">
                        </ea:GridColumn>
                        <ea:GridColumn ID="GridColumn8" runat="server" DataMember="PozycjaKorygowana.NazwaResztaLinii" Caption=" ">
                        </ea:GridColumn>
                        <ea:GridColumn runat="server" Width="15" Align="Right" DataMember="PozycjaKorygowana.Cena"
                            Caption="Cena netto|&lt;i&gt;Net unit price&lt;/i&gt;" ID="cenaprzed" RowSpan="2" EncodeHTML="True">
                        </ea:GridColumn>
                        <ea:GridColumn ID="GridColumn9" runat="server" Width="10" RightBorder="None" Align="Right" DataMember="PozycjaKorygowana.Ilosc.Value"
                            Caption="Ilość|&lt;i&gt;Quantity&lt;/i&gt;" RowSpan="2" EncodeHTML="True">
                        </ea:GridColumn>
                        <ea:GridColumn ID="GridColumn10" runat="server" Width="5" Align="Center" DataMember="PozycjaKorygowana.Ilosc.Symbol"
                            Caption="jm.|&lt;i&gt;unit&lt;/i&gt;" RowSpan="2" EncodeHTML="True">
                        </ea:GridColumn>
                        <ea:GridColumn runat="server" Width="8" Align="Right" DataMember="PozycjaKorygowana.Rabat"
                            Caption="Rabat|&lt;i&gt;Discount&lt;/i&gt;" ID="rabatprzed" RowSpan="2" EncodeHTML="True">
                        </ea:GridColumn>
                        <ea:GridColumn runat="server" Width="16" Align="Right" DataMember="PozycjaKorygowana.WartoscCy"
                            Caption="Wartość netto|&lt;i&gt;NET Value&lt;/i&gt;" ID="wartoscprzed" RowSpan="2" EncodeHTML="True">
                        </ea:GridColumn>
                        <ea:GridColumn runat="server" Width="10" Align="Right" DataMember="PozycjaKorygowana.DefinicjaStawki"
                            Caption="Stawka|&lt;i&gt;VAT rate&lt;/i&gt;" ID="vatprzed" RowSpan="2" EncodeHTML="True">
                        </ea:GridColumn>
                        <ea:GridColumn runat="server" Width="15" DataMember="PozycjaKorygowana.SWW" Caption="SWW/PKWiU"
                            ID="swwprzed" RowSpan="2" EncodeHTML="True">
                        </ea:GridColumn>
                    </Columns>
                </ea:Grid>
                Korekta / <em>Correction:</em>
                <ea:Grid ID="Grid4" runat="server" RowTypeName="Soneta.Handel.PozycjaDokHandlowego,Soneta.Handel" OnBeforeRow="Grid4_BeforeRow"
                    DataMember="Pozycje" RowsInRow="2">
                    <Columns>
                        <ea:GridColumn ID="GridColumn11" runat="server" Width="4" Align="Right" DataMember="#" Caption="Lp.|&lt;i&gt;#&lt;/i&gt;"
                            RowSpan="2" EncodeHTML="True">
                        </ea:GridColumn>
                        <ea:GridColumn ID="GridColumn12" runat="server" DataMember="NazwaPierwszaLinia" Caption="Nazwa towaru/usługi|&lt;i&gt;Product/service name&lt;/i&gt;" EncodeHTML="True">
                        </ea:GridColumn>
                        <ea:GridColumn ID="GridColumn13" runat="server" DataMember="NazwaResztaLinii" Caption=" ">
                        </ea:GridColumn>
                        <ea:GridColumn runat="server" Width="15" Align="Right" DataMember="Cena" Caption="Cena netto|&lt;i&gt;Net unit price&lt;/i&gt;"
                            ID="cenapo" RowSpan="2" EncodeHTML="True">
                        </ea:GridColumn>
                        <ea:GridColumn ID="GridColumn14" runat="server" Width="10" RightBorder="None" Align="Right" DataMember="ZmianaIlości.Value"
                            Caption="Zmiana ilości|&lt;i&gt;Quantity change&lt;/i&gt;" RowSpan="2" EncodeHTML="True">
                        </ea:GridColumn>
                        <ea:GridColumn ID="GridColumn15" runat="server" Width="5" Align="Center" DataMember="Ilosc.Symbol"
                            Caption="jm.|&lt;i&gt;unit&lt;/i&gt;" RowSpan="2" EncodeHTML="True">
                        </ea:GridColumn>
                        <ea:GridColumn runat="server" Width="8" Align="Right" DataMember="Rabat" Caption="Rabat|&lt;i&gt;Discount&lt;/i&gt;"
                            ID="rabatpo" RowSpan="2" EncodeHTML="True">
                        </ea:GridColumn>
                        <ea:GridColumn ID="GridColumn16" runat="server" Width="16" Align="Right" DataMember="ZmianaWartościCy"
                            Caption="Zmiana wartości|&lt;i&gt;Value change&lt;/i&gt;" RowSpan="2" EncodeHTML="True">
                        </ea:GridColumn>
                        <ea:GridColumn runat="server" Width="10" Align="Right" DataMember="DefinicjaStawki"
                            Caption="Stawka|&lt;i&gt;VAT rate&lt;/i&gt;" ID="vatpo" RowSpan="2" EncodeHTML="True">
                        </ea:GridColumn>
                        <ea:GridColumn runat="server" Width="15" DataMember="SWW" Caption="SWW/PKWiU" ID="swwpo"
                            RowSpan="2" EncodeHTML="True">
                        </ea:GridColumn>
                        <ea:GridColumn runat="server" ID="colRodzajKorekty" Caption="Zmiana|(Przyczyna korekty)|&lt;i&gt;Change of|(Correction reason)&lt;/i&gt;" DataMember="RodzajKorektyOpisEnglish" Width="16"
                            RowSpan="2"></ea:GridColumn>
                    </Columns>
                </ea:Grid>
                <ea:SectionMarker ID="SectionMarker5" runat="server" SectionType="Footer">
                </ea:SectionMarker>
            </ea:DataRepeater>

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
                                <em>Wartość zamówienia&nbsp;/&nbsp;<i>Order value</i>:</em>&nbsp;
                            </ea:Section>
                        </td>                    
                        <td align="right">
                            <ea:Grid ID="Grid_VATZamowienia" runat="server" RowTypeName="Soneta.Handel.DokumentZaliczkowy.SumaVATAdapter,Soneta.Handel"
                                DataMember="Workers.DokumentZaliczkowy.TabelaVAT" WithSections="False">
                                <Columns>
                                    <ea:GridColumn ID="GridColumn34" Width="15" Align="Right" DataMember="DefinicjaStawki" Total="Info"
                                        Caption="Stawka VAT|&lt;i&gt;VAT Percent&lt;/i&gt;" runat="server">
                                    </ea:GridColumn>
                                    <ea:GridColumn ID="Grid_VATZamowienia_NettoCy" Width="17" Align="Right" DataMember="Suma.NettoCy" Total="Sum" Caption="Netto|&lt;i&gt;NET Value&lt;/i&gt;"
                                        runat="server">
                                    </ea:GridColumn>
                                    <ea:GridColumn ID="GridColumn36" Width="17" Align="Right" DataMember="Suma.VATCy" Total="Sum" Caption="Kwota VAT|&lt;i&gt;VAT amount&lt;/i&gt;"
                                        Format="{0:n}" runat="server">
                                    </ea:GridColumn>
                                    <ea:GridColumn ID="GridColumn37" Width="17" Align="Right" DataMember="Suma.BruttoCy" Total="Sum" Caption="Brutto|&lt;i&gt;Value&lt;/i&gt;"
                                        runat="server">
                                    </ea:GridColumn>
                                </Columns>
                            </ea:Grid>
                        </td>
                    </tr>
                </table>
                <table id="Table6" style="width: 672px; height: 60px" cellspacing="0" cellpadding="0"
                width="672">
                    <tr>
                        <td style="width: 65px" align="right" width="65">
                            <br />
                            <br />
                        </td>
                        <td style="width: 445px; border-bottom: black 1px solid" valign="bottom" align="left"
                            width="145" colspan="1" rowspan="1">
                            <ea:DataLabel ID="DataLabelDopłataZaliczki" runat="server" Bold="False" Format="{0}:"></ea:DataLabel>
                        </td>
                        <td style="font-weight: bold; font-size: 18px; border-bottom: black 1px solid;
                            height: 22px" valign="bottom" align="right">
                            <ea:DataLabel ID="DataLabel46" runat="server" DataMember="Dokument.BruttoCy" Bold="False">
                            </ea:DataLabel>
                        </td>
                    </tr>
                    <tr>
                        <td style="width: 65px" align="right">
                        </td>
                        <td style="width: 246px" align="left">
                            <font size="2"><em>Słownie:</em></font></td>
                        <td align="right">
                            <font size="2"><em>
                                <ea:DataLabel ID="DataLabel48" runat="server" DataMember="Dokument.BruttoCy" Bold="False"
                                    Format="{0:+t}">
                                </ea:DataLabel>
                            </em></font>
                        </td>
                    </tr>
                <tr>
                    <td style="width: 65px" align="right">
                    </td>
                    <td style="width: 246px" align="left">
                        <em><font size="2">In words:</font></em></td>
                    <td align="right">
                        <em><font size="2">
                            <ea:DataLabel ID="DataLabel49" runat="server" DataMember="Dokument.BruttoCy" Bold="False"
                                Format="{0:+e}">
                            </ea:DataLabel>
                        </font></em>
                    </td>
                </tr>                    
                </table>                
            </ea:Section>

            <ea:Section ID="SectionVATZaliczkowego" runat="server" Width="100%">
                <table cellpadding="0" cellspacing="0" border="0">
                    <tr>
                        <td width="100%" style="font-size: 13px; text-align:right; vertical-align:bottom;">
                            <em>Wartość zamówienia&nbsp;/&nbsp;<i>Order value</i>:</em>&nbsp;
                        </td>
                        <td align="right">
                            <ea:Grid ID="Grid_VATZaliczkowego" runat="server" RowTypeName="Soneta.Handel.DokumentZaliczkowy.SumaVATAdapter,Soneta.Handel"
                                DataMember="Workers.DokumentZaliczkowy.TabelaVAT"  WithSections="False">
                                <Columns>
                                    <ea:GridColumn Width="15" Align="Right" DataMember="DefinicjaStawki" Total="Info"
                                        Caption="Stawka VAT|&lt;i&gt;VAT Percent&lt;/i&gt;" runat="server">
                                    </ea:GridColumn>
                                    <ea:GridColumn ID="Grid_VATZaliczkowego_NettoCy" Width="17" Align="Right" DataMember="Suma.NettoCy" Total="Sum" Caption="Netto|&lt;i&gt;NET Value&lt;/i&gt;"
                                        runat="server">
                                    </ea:GridColumn>
                                    <ea:GridColumn Width="17" Align="Right" DataMember="Suma.VATCy" Total="Sum" Caption="Kwota VAT|&lt;i&gt;VAT amount&lt;/i&gt;"
                                        Format="{0:n}" runat="server">
                                    </ea:GridColumn>
                                    <ea:GridColumn Width="17" Align="Right" DataMember="Suma.BruttoCy" Total="Sum" Caption="Brutto|&lt;i&gt;Value&lt;/i&gt;"
                                        runat="server">
                                    </ea:GridColumn>
                                </Columns>
                            </ea:Grid>
                        </td>
                    </tr>
                </table>
                <table id="Table2" style="width: 672px; height: 60px" cellspacing="0" cellpadding="0"
                width="672">
                <tr>
                    <td style="width: 65px" align="right" width="65">
                    </td>
                    <td style="width: 246px; border-bottom: black 1px solid" valign="bottom" align="left"
                        width="246" colspan="1" rowspan="1">Kwota zaliczki&nbsp;/&nbsp;<i>Advance value</i>:</td>
                    <td style="font-weight: bold; font-size: 18px; border-bottom: black 1px solid;
                        height: 22px" valign="bottom" align="right">
                        <ea:DataLabel ID="DataLabel50" runat="server" DataMember="Dokument.BruttoCy" Bold="False">
                        </ea:DataLabel>
                    </td>
                </tr>
                <tr>
                    <td style="width: 65px" align="right">
                    </td>
                    <td style="width: 246px" align="left">
                        <font size="2">Słownie:</font></td>
                    <td align="right">
                        <font size="2">
                            <ea:DataLabel ID="DataLabel60" runat="server" DataMember="Dokument.BruttoCy" Bold="False"
                                Format="{0:+t}">
                            </ea:DataLabel>
                        </font>
                    </td>
                </tr>
                <tr>
                    <td style="width: 65px" align="right">
                    </td>
                    <td style="width: 246px" align="left">
                        <em><font size="2">In words:</font></em></td>
                    <td align="right">
                        <em><font size="2">
                            <ea:DataLabel ID="DataLabel380" runat="server" DataMember="Dokument.BruttoCy" Bold="False"
                                Format="{0:+e}">
                            </ea:DataLabel>
                        </font></em>
                    </td>
                </tr>
            </table>
            </ea:Section>
            <ea:DataRepeater ID="DataRepeater4" runat="server" Width="100%">
                <ea:SectionMarker ID="SectionMarker6" runat="server">
                </ea:SectionMarker>
                <table cellpadding="0" cellspacing="0" border="0">
                    <tr>
                        <td width="15%" style="font-size: 10px;">
                            <ea:DataLabel ID="DataLabel24" runat="server" DataMember="Wydruk.InfoKorekty1" Bold="False">
                            </ea:DataLabel>
                            <br />
                            <ea:DataLabel ID="DataLabel23" runat="server" DataMember="Wydruk.InfoKorekty2" Bold="False">
                            </ea:DataLabel>
                        </td>
                        <td width="100%" style="font-size: 13px; text-align:right; vertical-align:bottom;">
                            <ea:Section runat="server" id="TabelaVatZaliczkiNapis">
                                <em>Tabela VAT zaliczki / Table advance payment VAT:</em>&nbsp;
                            </ea:Section>
                            <ea:Section runat="server" id="TabelaVatKoncowegoNapis">
                                <em>Tabela VAT dopłaty do zaliczki / Table of the advance VAT payments:</em>&nbsp;
                            </ea:Section>                            
                        </td>                          
                        <td align="right">
                            <ea:Grid ID="Grid_SumyVat" runat="server" RowTypeName="Soneta.Handel.SumaVAT,Soneta.Handel"
                                DataMember="SumyVAT" WithSections="False">
                                <Columns>
                                    <ea:GridColumn ID="GridColumn17" runat="server" Width="15" Align="Right" DataMember="DefinicjaStawki"
                                        Total="Info" Caption="Stawka VAT|&lt;i&gt;VAT Percent&lt;/i&gt;" EncodeHTML="True">
                                    </ea:GridColumn>
                                    <ea:GridColumn ID="Grid_SumyVat_NettoCy" runat="server" Width="17" Align="Right" DataMember="Suma.NettoCy"
                                        Total="Sum" Caption="Netto|&lt;i&gt;NET Value&lt;/i&gt;" EncodeHTML="True">
                                    </ea:GridColumn>
                                    <ea:GridColumn ID="GridColumn19" runat="server" Width="17" Align="Right" DataMember="Suma.VATCy" Total="Sum"
                                        Caption="Kwota VAT|&lt;i&gt;VAT amount&lt;/i&gt;" Format="{0:n}" EncodeHTML="True">
                                    </ea:GridColumn>
                                    <ea:GridColumn ID="GridColumn20" runat="server" Width="17" Align="Right" DataMember="Suma.BruttoCy"
                                        Total="Sum" Caption="Brutto|&lt;i&gt;Value&lt;/i&gt;" EncodeHTML="True">
                                    </ea:GridColumn>
                                </Columns>
                            </ea:Grid>
                        </td>
                    </tr>
                </table>
                <ea:SectionMarker ID="SectionMarker7" runat="server" SectionType="Footer">
                </ea:SectionMarker>
            </ea:DataRepeater>
            <ea:Section ID="Section4" runat="server" DataMember="Dokument.Wydruk.JestSumaPozycji"
                Width="100%">
                Suma&nbsp;brutto dokumentu / <em>Total gross value:</em>
                <ea:DataLabel ID="DataLabel41" runat="server" Bold="False" DataMember="Dokument.SumaPozycji.Brutto" EncodeHTML="True">
                </ea:DataLabel>
                &nbsp;PLN<br>
            </ea:Section>
            <ea:Section ID="sectionZaliczki" runat="server" DataMember="Dokument.DokumentyZaliczkowe">
                Faktury zaliczkowe /<em> &nbsp;Advance invoices:<br>
                </em>
                <ea:Grid ID="gridZaliczki" runat="server" RowTypeName="Soneta.Handel.DokumentHandlowy,Soneta.Handel"
                    DataMember="Dokument.Wydruk.DokumentyZaliczkowe" WithSections="False" OnBeforeRow="gridZaliczki_BeforeRow">
                    <Columns>
                        <ea:GridColumn ID="GridColumn21" runat="server" Width="4" Align="Right" DataMember="#" Caption="Lp.|&lt;i&gt;#&lt;/i&gt;" EncodeHTML="True">
                        </ea:GridColumn>
                        <ea:GridColumn ID="GridColumn22" runat="server" Width="30" DataMember="Numer" Caption="Numer|&lt;i&gt;Number&lt;/i&gt;" EncodeHTML="True">
                        </ea:GridColumn>
                        <ea:GridColumn ID="GridColumn23" runat="server" Width="15" Align="Center" DataMember="Data" Caption="Data|&lt;i&gt;Date&lt;/i&gt;" EncodeHTML="True">
                        </ea:GridColumn>
                        <ea:GridColumn ID="GridColumn24" runat="server" Width="18" Align="Right" DataMember="BruttoCy" Caption="Wartość|&lt;i&gt;Value&lt;/i&gt;" EncodeHTML="True">
                        </ea:GridColumn>
                        <ea:GridColumn runat="server" Width="18" Align="Right" Total="Sum" ID="colZaliczka" EncodeHTML="True"
                            Caption="Rozliczona zaliczka|&lt;i&gt;Settled in advance&lt;/i&gt;"></ea:GridColumn>
                    </Columns>
                </ea:Grid>
                <br>
            </ea:Section>
            <table id="Table3" style="width: 672px; height: 60px" cellspacing="0" cellpadding="0"
                width="672">
                <tr>
                    <td colspan="3">

                        <i> 
                        <br />
                      <font size="2">uwagi : <ea:DataLabel runat="server" ID="uwagi" Bold="false"> </ea:DataLabel></font></i><br/><font size="1"><i>Remarks</i></font>

                    </td>
               </tr>




                <tr>                    
                    <td style="width: 65px" align="right" width="65">
                    </td>
                    <td style="width: 246px; border-bottom: black 1px solid" valign="bottom" align="left"
                        width="246" colspan="1" rowspan="1">
                        <ea:DataLabel ID="doZaplaty" runat="server" DataMember="Dokument.Wydruk.KierunekZapłaty"
                            Bold="False" Format="{0}:">
                            <ValuesMap>
                                <ea:ValuesPair Key="Do zapłaty" Value="Do zapłaty / &lt;i&gt;To be paid&lt;/i&gt;"></ea:ValuesPair>
                                <ea:ValuesPair Key="Do zwrotu" Value="Do zwrotu / &lt;i&gt;To be refunded&lt;/i&gt;"></ea:ValuesPair>
                                <ea:ValuesPair Key="Wartość" Value="Wartość / &lt;i&gt;Value&lt;/i&gt;" />
                                <ea:ValuesPair Key="Zapłacona zaliczka" Value="Kwota zaliczki / &lt;i&gt;Advance value&lt;/i&gt;"></ea:ValuesPair>
                                <ea:ValuesPair Key="Zwr&#243;cona zaliczka" Value="Zwr&#243;cona zaliczka / &lt;i&gt;Advance be refunded&lt;/i&gt;"></ea:ValuesPair>
                            </ValuesMap>
                        </ea:DataLabel>
                    </td>
                    <td style="font-weight: bold; font-size: 18px; border-bottom: black 1px solid;
                        height: 22px" valign="bottom" align="right">
                        <ea:DataLabel ID="DataLabel5" runat="server" DataMember="Dokument.Wydruk.BruttoCyPlus" Bold="False">
                        </ea:DataLabel>
                    </td>
                </tr>
                <tr>
                    <td style="width: 65px" align="right">
                    </td>
                    <td style="width: 246px" align="left">
                        <font size="2">Słownie: </font></td>
                    <td align="right">
                        <font size="2">
                            <ea:DataLabel ID="DataLabel6" runat="server" DataMember="Dokument.BruttoCy" Bold="False"
                                Format="{0:+t}">
                            </ea:DataLabel>
                        </font>
                    </td>
                </tr>
                <tr>
                    <td style="width: 65px" align="right">
                    </td>
                    <td style="width: 246px" align="left">
                        <em><font size="2">In words:</font></em></td>
                    <td align="right">
                        <em><font size="2">
                            <ea:DataLabel ID="DataLabel38" runat="server" DataMember="Dokument.BruttoCy" Bold="False"
                                Format="{0:+e}">
                            </ea:DataLabel>
                        </font></em>
                    </td>
                </tr>
            </table>
            <ea:Section ID="sectionWplaty" runat="server" DataMember="Dokument.Zaliczki">
                Rozliczone zaliczki /<em> Advances cleared:<br>
                </em>
                <ea:Grid ID="Grid2" runat="server" RowTypeName="Soneta.Handel.RelacjaZaliczki,Soneta.Handel"
                    DataMember="Dokument.Zaliczki" WithSections="False">
                    <Columns>
                        <ea:GridColumn ID="GridColumn25" runat="server" Width="4" Align="Right" DataMember="#" Caption="Lp.|&lt;i&gt;#&lt;/i&gt;">
                        </ea:GridColumn>
                        <ea:GridColumn ID="GridColumn26" runat="server" Width="20" DataMember="Zaplata.SposobZaplaty" Caption="Spos&#243;b zapłaty|&lt;i&gt;Mode of payment&lt;/i&gt;">
                        </ea:GridColumn>
                        <ea:GridColumn ID="GridColumn27" runat="server" Width="18" Align="Center" DataMember="Zaplata.DataDokumentu"
                            Caption="Data|&lt;i&gt;Date&lt;/i&gt;">
                        </ea:GridColumn>
                        <ea:GridColumn ID="GridColumn28" runat="server" Width="20" Align="Right" DataMember="Kwota" Caption="Kwota|&lt;i&gt;Amount&lt;/i&gt;">
                        </ea:GridColumn>
                        <ea:GridColumn ID="GridColumn29" runat="server" Width="25" DataMember="Zaplata.NumerDokumentu" Caption="Numer|&lt;i&gt;Number&lt;/i&gt;">
                        </ea:GridColumn>
                    </Columns>
                </ea:Grid>
            </ea:Section>
            <br>
            <ea:Section ID="Section1" runat="server" DataMember="Dokument.Wydruk.ZapłataCzęściowa">
                <ea:DataLabel ID="DataLabel26" runat="server" DataMember="Dokument.Wydruk.Zapłacono"
                    Bold="False">
                </ea:DataLabel>
                &nbsp;
                <ea:DataLabel ID="DataLabel29" runat="server" DataMember="Dokument.Wydruk.SposobZaplaty"
                    Bold="False">
                </ea:DataLabel>
                &nbsp;/ <em>
                    <ea:DataLabel ID="DataLabel34" runat="server" DataMember="Dokument.Wydruk.ZapłaconoEng"
                        Bold="False">
                    </ea:DataLabel>
                    <ea:DataLabel ID="DataLabel33" runat="server" DataMember="Dokument.Wydruk.SposobZaplaty"
                        Bold="False">
                        <ValuesMap>
                            <ea:ValuesPair Key="" Value=""></ea:ValuesPair>
                            <ea:ValuesPair Key="czekiem" Value="by cheque"></ea:ValuesPair>
                            <ea:ValuesPair Key="got&#243;wką" Value="cash"></ea:ValuesPair>
                            <ea:ValuesPair Key="kartą" Value="a card"></ea:ValuesPair>
                            <ea:ValuesPair Key="kredytem" Value="credit"></ea:ValuesPair>
                            <ea:ValuesPair Key="pobraniem" Value="on delivery"></ea:ValuesPair>
                            <ea:ValuesPair Key="przekazem pocztowym" Value="postal order"></ea:ValuesPair>
                            <ea:ValuesPair Key="przelewem" Value="transfer"></ea:ValuesPair>
                            <ea:ValuesPair Key="zaliczeniem pocztowym" Value="postal delivery"></ea:ValuesPair>
                        </ValuesMap>
                    </ea:DataLabel>
                </em>: <strong>
                    <ea:DataLabel ID="DataLabel35" runat="server" DataMember="Dokument.Wydruk.ZaplatySlownieUpr"
                        Bold="False">
                    </ea:DataLabel>
                </strong>
            </ea:Section>
            <ea:Section ID="Section2" runat="server" DataMember="Dokument.Wydruk.ZapłataCałkowita">
                <ea:DataLabel ID="DataLabel31" runat="server" DataMember="Dokument.Wydruk.Zapłacono">
                </ea:DataLabel>
                &nbsp;
                <ea:DataLabel ID="DataLabel30" runat="server" DataMember="Dokument.Zapłata.SposobZaplaty.Biernik">
                </ea:DataLabel>
                &nbsp;/ <em>
                    <ea:DataLabel ID="DataLabel37" runat="server" DataMember="Dokument.Wydruk.ZapłaconoEng">
                    </ea:DataLabel>
                    
                    <ea:DataLabel ID="DataLabel36" runat="server" DataMember="Dokument.Zapłata.SposobZaplaty.Biernik">
                        <ValuesMap>
                            <ea:ValuesPair Key="" Value=""></ea:ValuesPair>
                            <ea:ValuesPair Key="czekiem" Value="by cheque"></ea:ValuesPair>
                            <ea:ValuesPair Key="got&#243;wką" Value="cash"></ea:ValuesPair>
                            <ea:ValuesPair Key="kartą" Value="a card"></ea:ValuesPair>
                            <ea:ValuesPair Key="kredytem" Value="credit"></ea:ValuesPair>
                            <ea:ValuesPair Key="pobraniem" Value="on delivery"></ea:ValuesPair>
                            <ea:ValuesPair Key="przekazem pocztowym" Value="postal order"></ea:ValuesPair>
                            <ea:ValuesPair Key="przelewem" Value="transfer"></ea:ValuesPair>
                            <ea:ValuesPair Key="zaliczeniem pocztowym" Value="postal delivery"></ea:ValuesPair>
                        </ValuesMap>
                    </ea:DataLabel>
                </em><br />
            </ea:Section>
             <!-- Mateusz - zapłata zaliczkami 100% -->
            <ea:Section runat="server" DataMember="Dokument.Wydruk.ZaliczkaPokrywaCałość">
                    Pozostało do zapłaty /<em> To be paid: 0 <%=Parametry.Dokument.BruttoCy.Symbol %>.</em><br />
            </ea:Section>
            <ea:Section ID="sectionNiezaplacone" runat="server" DataMember="Dokument.Wydruk.SąNiezapłacone">
                <ea:DataLabel ID="DataLabel44" runat="server" DataMember="Dokument.Wydruk.KierunekZapłaty" Bold="False" Format="{0}:">
                    <ValuesMap>
                        <ea:ValuesPair Key="Do zapłaty" Value="Do zapłaty / &lt;i&gt;To be paid&lt;/i&gt;"></ea:ValuesPair>
                        <ea:ValuesPair Key="Do zwrotu" Value="Do zwrotu / &lt;i&gt;To be refunded&lt;/i&gt;"></ea:ValuesPair>
                        <ea:ValuesPair Key="Wartość" Value="Wartość / &lt;i&gt;Value&lt;/i&gt;" />
                        <ea:ValuesPair Key="Zapłacona zaliczka" Value="Do zapłaty / &lt;i&gt;To be paid&lt;/i&gt;"></ea:ValuesPair>
                        <ea:ValuesPair Key="Zwr&#243;cona zaliczka" Value="Zwr&#243;cona zaliczka / &lt;i&gt;Advance be refunded&lt;/i&gt;"></ea:ValuesPair>
                    </ValuesMap>
                </ea:DataLabel>
               
                <ea:Grid ID="niezapłacone" runat="server" OnBeforeRow="niezapłacone_BeforeRow" RowTypeName="Soneta.Kasa.Platnosc,Soneta.Kasa"
                    DataMember="Dokument.Wydruk.Niezapłacone" WithSections="False">
                    <Columns>
                        <ea:GridColumn ID="GridColumn30" runat="server" Width="4" Align="Right" DataMember="#" Caption="Lp.|&lt;i&gt;#&lt;/i&gt;">
                        </ea:GridColumn>
                        <ea:GridColumn ID="GridColumn31" runat="server" Width="20" DataMember="Płatność.SposobZaplaty" Caption="Spos&#243;b zapłaty|&lt;i&gt;Mode of payment&lt;/i&gt;">
                        </ea:GridColumn>
                        <ea:GridColumn ID="GridColumn32" runat="server" Width="18" Align="Center" DataMember="Płatność.Termin"
                            Caption="Termin|&lt;i&gt;To be paid until&lt;/i&gt;">
                        </ea:GridColumn>
                        <ea:GridColumn ID="GridColumn33" runat="server" Width="20" Align="Right" DataMember="Kwota" Caption="Kwota|&lt;i&gt;Amount&lt;/i&gt;">
                        </ea:GridColumn>
                        <ea:GridColumn runat="server" Caption="Płatnik|&lt;i&gt;Payment by&lt;/i&gt;" Format="{0:H}"
                            ID="platnik">
                        </ea:GridColumn>
                    </Columns>
                </ea:Grid>
            </ea:Section>
			
            <ea:Section ID="sectionNumeryNadrzednych" runat="server" DataMember="Dokument.Wydruk.CzyDrukowacNumeryPowiazanych" >
				<div style="margin: 5px 0px 5px 0px">
                    
					<em>Dokumenty powiązane / <i>Related documents</i>:</em>
					<div style="font-size: 13px; left: 10px; font-family: Tahoma; position: relative">
						<ea:DataLabel ID="labelNumeryNadrzednych" runat="server" DataMember="Dokument.Wydruk.NumeryNadrzędneZK" Bold="False" ></ea:DataLabel>
						<ea:DataLabel ID="labelNumeryPodrzednych" runat="server" DataMember="Dokument.Wydruk.NumeryPodrzędneBK" Bold="False" ></ea:DataLabel>
					</div>
				</div>
            </ea:Section>
			
			<ea:Section runat="server" DataMember="Dokument.Wydruk.CzyDrukowacNumeryKorekt">
				<div style="margin: 5px 0px 5px 0px">
					<em>Poprzednie korekty / <i>Previous corrections</i>:</em>
					<div style="font-size: 13px; left: 10px; font-family: Tahoma; position: relative">
						<ea:DataLabel runat="server" DataMember="Dokument.Wydruk.NumeryPoprzednichKorekt" Bold="false"></ea:DataLabel>
					</div>
				</div>
            </ea:Section>
			
            <p style="font-family: Tahoma, Arial; font-size: 13px;">
                <ea:DataLabel ID="OpisDok" runat="server" DataMember="Dokument.Opis" Bold="False"> </ea:DataLabel>
            </p>
            <p style="font-family: Tahoma, Arial; font-size: 13px;">
                <ea:DataLabel ID="OpisWydruku" runat="server" DataMember="Dokument.Wydruk.OpisWydruku" Bold="False"> </ea:DataLabel>
            </p>
            
            
                <p style="font-family: Tahoma, Arial; font-size: 13px;">
                    <strong>Do rozliczania podatku VAT zobowiązany jest nabywca usługi (odwrotne obciążenie)<br /></strong>                       
            <span style="font-family: Tahoma, Arial; font-size: 9px;">

                <em>Levy of VAT reverse charged to recipent of service (reverse charge)</em><br /></span></p>
            <table style="width: 100%;">
                <tr>
                    <td style="text-align:center;">
                        <ea:DataLabel ID="stPodpis" runat="server" Bold="False">
                        </ea:DataLabel>
                    </td>
                    <td style="text-align:center;">
                        <ea:DataLabel ID="stOsoba" runat="server" Bold="False">
                        </ea:DataLabel>
                    </td>
                </tr>
            </table>
            <ea:SectionMarker ID="SectionMarker8" runat="server" SectionType="Footer">
            </ea:SectionMarker>
    </ea:DataRepeater> 
</FORM></BODY></HTML>

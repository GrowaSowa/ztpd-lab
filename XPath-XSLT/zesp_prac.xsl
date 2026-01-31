<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:template match="/">
        <html>
            <head></head>
            <body>
                <h1>ZESPOŁY:</h1>
                <ol>
<!--                    <xsl:for-each select="ZESPOLY/ROW">-->
<!--                        <li><xsl:value-of select="NAZWA"/></li>-->
<!--                    </xsl:for-each>-->
                    <xsl:apply-templates select="ZESPOLY/ROW" mode="list"/>
                </ol>
                <xsl:apply-templates select="ZESPOLY/ROW" mode="details"/>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="ZESPOLY/ROW" mode="list">
        <li><a href="#{ID_ZESP}"><xsl:value-of select="NAZWA"/></a></li>
    </xsl:template>
    <xsl:template match="ZESPOLY/ROW" mode="details">
        <h2 id="{ID_ZESP}">NAZWA: <xsl:value-of select="NAZWA"/><br/>
        ADRES: <xsl:value-of select="ADRES"/></h2>
        <xsl:if test="count(PRACOWNICY/ROW) > 0">
            <table>
                <tr>
                    <th>Nazwisko</th>
                    <th>Etat</th>
                    <th>Zatrudniony</th>
                    <th>Placa pod.</th>
                    <th>Szef</th>
                </tr>
                <xsl:apply-templates select="PRACOWNICY/ROW">
                    <xsl:sort select="NAZWISKO"/>
                </xsl:apply-templates>
            </table>
        </xsl:if>
        Liczba pracowników: <xsl:value-of select="count(PRACOWNICY/ROW)"/>
    </xsl:template>
    <xsl:template match="PRACOWNICY/ROW">
        <tr>
            <td><xsl:value-of select="NAZWISKO"/></td>
            <td><xsl:value-of select="ETAT"/></td>
            <td><xsl:value-of select="ZATRUDNIONY"/></td>
            <td><xsl:value-of select="PLACA_POD"/></td>
<!--            <td><xsl:value-of select="ID_SZEFA"/></td>-->
            <xsl:call-template name="nazwisko-szefa">
                <xsl:with-param name="sid" select="ID_SZEFA"/>
            </xsl:call-template>
        </tr>
    </xsl:template>
    <xsl:template name="nazwisko-szefa">
        <xsl:param name="sid"/>
        <td>
            <xsl:choose>
                <xsl:when test="//ZESPOLY/ROW/PRACOWNICY/ROW[ID_PRAC=$sid]/NAZWISKO">
                    <xsl:value-of select="//ZESPOLY/ROW/PRACOWNICY/ROW[ID_PRAC=$sid]/NAZWISKO"/>
                </xsl:when>
                <xsl:otherwise>
                    brak
                </xsl:otherwise>
            </xsl:choose>
        </td>
    </xsl:template>
</xsl:stylesheet>
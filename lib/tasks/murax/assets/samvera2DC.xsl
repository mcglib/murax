<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:fo="http://www.w3.org/1999/XSL/Format" 
  xmlns:dce="http://purl.org/dc/elements/1.1/" 
  xmlns:dct="http://purl.org/dc/terms/" 
  xmlns:frapo="http://purl.org/cerif/frapo/"
  xmlns:bibo="http://purl.org/ontology/bibo/"
  xmlns:ns1="http://escholarship.mcgill.ca/">

<xsl:output method="xml" indent="yes"/>

<xsl:template match="records">
  <records>
  <xsl:apply-templates />
  </records>
</xsl:template>

<xsl:template match="record">
  <record>
    <xsl:apply-templates/>
  </record>
</xsl:template>
  
<xsl:template match="//record/id">
  <xsl:choose>
    <xsl:when test="@order">
      <xsl:element name="ns1:{'workid'}"><xsl:attribute name="order"><xsl:value-of select="@order"/></xsl:attribute><xsl:value-of select="."/></xsl:element>
    </xsl:when>
    <xsl:otherwise>
      <xsl:element name="ns1:{'workid'}"><xsl:value-of select="."/></xsl:element>      
    </xsl:otherwise>
  </xsl:choose></xsl:template>

<xsl:template match="//record/title[not(@nil='true')]">
  <xsl:choose>
    <xsl:when test="@order">
      <xsl:element name="dce:{'title'}"><xsl:attribute name="order"><xsl:value-of select="@order"/></xsl:attribute><xsl:value-of select="."/></xsl:element>
    </xsl:when>
    <xsl:otherwise>
      <xsl:element name="dce:{'title'}"><xsl:value-of select="."/></xsl:element>      
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="//record/alternative-title[not(@nil='true')]">
  <xsl:choose>
    <xsl:when test="@order">
      <xsl:element name="dct:{'alternative'}"><xsl:attribute name="order"><xsl:value-of select="@order"/></xsl:attribute></xsl:element>
    </xsl:when>
    <xsl:otherwise>
       <xsl:element name="dct:{'alternative'}"><xsl:value-of select="."/></xsl:element>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>
  
<xsl:template match="//record/creator[not(@nil='true')]">
  <xsl:choose>
    <xsl:when test="@order">
      <xsl:element name="dce:{'creator'}"><xsl:attribute name="order"><xsl:value-of select="@order"/></xsl:attribute><xsl:value-of select="."/></xsl:element>
    </xsl:when>
  <xsl:otherwise>
  <xsl:element name="dce:{'creator'}"><xsl:value-of select="."/></xsl:element>
  </xsl:otherwise>
  </xsl:choose>
</xsl:template>
 
<xsl:template match="//record/contributor[not(@nil='true')]">
  <xsl:choose>
    <xsl:when test="@order">
      <xsl:element name="dce:{'contributor'}"><xsl:attribute name="order"><xsl:value-of select="@order"/></xsl:attribute><xsl:value-of select="."/></xsl:element>
    </xsl:when>
    <xsl:otherwise>
      <xsl:element name="dce:{'contributor'}"><xsl:value-of select="."/></xsl:element>      
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="//record/publisher[not(@nil='true')]">
  <xsl:choose>
    <xsl:when test="@order">
      <xsl:element name="dce:{'publisher'}"><xsl:attribute name="order"><xsl:value-of select="@order"/></xsl:attribute><xsl:value-of select="."/></xsl:element>
    </xsl:when>
    <xsl:otherwise>
    <xsl:element name="dce:{'publisher'}"><xsl:value-of select="."/></xsl:element>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="record/date">
  <xsl:choose>
    <xsl:when test="@order">
      <xsl:element name="dce:{'date'}"><xsl:attribute name="order"><xsl:value-of select="@order"/></xsl:attribute><xsl:value-of select="."/></xsl:element>
    </xsl:when>
    <xsl:otherwise>
      <xsl:element name="dce:{'date'}"><xsl:value-of select="."/></xsl:element>      
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>
  
<xsl:template match="//record/abstract[not(@nil='true')]">
  <xsl:choose>
    <xsl:when test="@order">
      <xsl:element name="dct:{'abstract'}"><xsl:attribute name="order"><xsl:value-of select="@order"/></xsl:attribute><xsl:value-of select="."/></xsl:element>
    </xsl:when>
    <xsl:otherwise>
      <xsl:element name="dct:{'abstract'}"><xsl:value-of select="."/></xsl:element>      
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="//record/description[not(@nil='true')]">
  <xsl:choose>
    <xsl:when test="@order">
      <xsl:element name="dce:{'description'}"><xsl:attribute name="order"><xsl:value-of select="@order"/></xsl:attribute><xsl:value-of select="."/></xsl:element>
    </xsl:when>
    <xsl:otherwise>
      <xsl:element name="dce:{'description'}"><xsl:value-of select="."/></xsl:element>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="//record/language[not(@nil='true')]">
  <xsl:choose>
    <xsl:when test="@order">
      <xsl:element name="dce:{'language'}"><xsl:attribute name="order"><xsl:value-of select="@order"/></xsl:attribute><xsl:value-of select="."/></xsl:element>
    </xsl:when>
    <xsl:otherwise>
      <xsl:element name="dce:{'language'}"><xsl:value-of select="."/></xsl:element>      
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="//record/department[not(@nil='true')]">
  <xsl:choose>
    <xsl:when test="@order">
      <xsl:element name="frapo:{'department'}"><xsl:attribute name="order"><xsl:value-of select="@order"/></xsl:attribute><xsl:value-of select="."/></xsl:element>
    </xsl:when>
    <xsl:otherwise>
    <xsl:element name="frapo:{'department'}"><xsl:value-of select="."/></xsl:element>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="//record/faculty[not(@nil='true')]">
  <xsl:choose>
    <xsl:when test="@order">
      <xsl:element name="frapo:{'faculty'}"><xsl:attribute name="order"><xsl:value-of select="@order"/></xsl:attribute><xsl:value-of select="."/></xsl:element>
    </xsl:when>
    <xsl:otherwise>
      <xsl:element name="frapo:{'faculty'}"><xsl:value-of select="."/></xsl:element>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>
  
<xsl:template match="//record/degree[not(@nil='true')]">
  <xsl:choose>
    <xsl:when test="@order">
      <xsl:element name="bibo:{'degree'}"><xsl:attribute name="order"><xsl:value-of select="@order"/></xsl:attribute><xsl:value-of select="."/></xsl:element>
    </xsl:when>
    <xsl:otherwise>
      <xsl:element name="bibo:{'degree'}"><xsl:value-of select="."/></xsl:element>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="//record/subject[not(@nil='true')]">
  <xsl:choose>
    <xsl:when test="@order">
      <xsl:element name="dce:{'subject'}"><xsl:attribute name="order"><xsl:value-of select="@order"/></xsl:attribute><xsl:value-of select="."/></xsl:element>
    </xsl:when>
    <xsl:otherwise>
      <xsl:element name="dce:{'subject'}"><xsl:value-of select="."/></xsl:element>      
    </xsl:otherwise>
  </xsl:choose>
</xsl:template> 
  
<xsl:template match="//record/identifier[not(@nil='true')]">
  <xsl:choose>
    <xsl:when test="@order">
      <xsl:element name="dce:{'identifier'}"><xsl:attribute name="order"><xsl:value-of select="@order"/></xsl:attribute><xsl:value-of select="."/></xsl:element>
    </xsl:when>
    <xsl:otherwise>
      <xsl:element name="dce:{'identifier'}"><xsl:value-of select="."/></xsl:element>      
    </xsl:otherwise>
  </xsl:choose>
</xsl:template> 

<xsl:template match="//record/relation[not(@nil='true')]">
  <xsl:choose>
    <xsl:when test="@order">
      <xsl:element name="dce:{'relation'}"><xsl:attribute name="order"><xsl:value-of select="@order"/></xsl:attribute><xsl:value-of select="."/></xsl:element>
    </xsl:when>
    <xsl:otherwise>
      <xsl:element name="dce:{'relation'}"><xsl:value-of select="."/></xsl:element>      
    </xsl:otherwise>
  </xsl:choose>
</xsl:template> 

<xsl:template match="//record/rtype[not(@nil='true')]">
  <xsl:choose>
    <xsl:when test="@order">
      <xsl:element name="dce:{'type'}"><xsl:attribute name="order"><xsl:value-of select="@order"/></xsl:attribute><xsl:value-of select="."/></xsl:element>
    </xsl:when>
    <xsl:otherwise>
      <xsl:element name="dce:{'type'}"><xsl:value-of select="."/></xsl:element>      
    </xsl:otherwise>
  </xsl:choose>
</xsl:template> 

<!-- additional elements not in DCE, DCT, BIBO or FRAPO namespaces -->
  

  <xsl:template match="//record/*[not(self::id 
    or self::title 
    or self::alternative-title 
    or self::creator 
    or self::contributor 
    or self::publisher 
    or self::date 
    or self::abstract
    or self::description
    or self::language
    or self::department
    or self::faculty
    or self::degree
    or self::subject
    or self::identifier
    or self::rtype
    or self::relation
    or @nil='true'
    )]">
  <xsl:choose>
  <xsl:when test="@order">
  <xsl:element name="ns1:{name(.)}"><xsl:attribute name="order"><xsl:value-of select="./@order"/></xsl:attribute><xsl:value-of select="."/></xsl:element>
  </xsl:when>
  <xsl:otherwise>
    <xsl:element name="ns1:{name(.)}"><xsl:value-of select="."/></xsl:element>
  </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="text()">
</xsl:template>
  
</xsl:stylesheet>

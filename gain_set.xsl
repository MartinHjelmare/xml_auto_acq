<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output indent="yes"/>
	<!-- JobId / BlockId -->
	<xsl:param name="BLOCKID"/>
	<!-- Attributes to change -->
	<xsl:param name="CHANNEL" select="'0'"/>
	<xsl:param name="GAIN" select="'0'"/>

	<xsl:template match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*"/>
		</xsl:copy>
	</xsl:template>
	
	<!-- Green -->
	<xsl:template match="Configuration/LDM_Block_Sequence/LDM_Block_Sequence_Block_List/LDM_Block_Sequence_Block/LDM_Block_Sequential/LDM_Block_Sequential_List/ATLConfocalSettingDefinition[1]/DetectorList/Detector[@Channel='1']/@Gain">
		<xsl:choose>
			<xsl:when test="$CHANNEL='green' and ../../../../../../@BlockID=$BLOCKID">
				<xsl:attribute name="Gain">
					<xsl:value-of select="$GAIN"/>
				</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="Gain">
					<xsl:value-of select="."/>
				</xsl:attribute>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Blue -->
	<xsl:template match="Configuration/LDM_Block_Sequence/LDM_Block_Sequence_Block_List/LDM_Block_Sequence_Block/LDM_Block_Sequential/LDM_Block_Sequential_List/ATLConfocalSettingDefinition[2]/DetectorList/Detector[@Channel='1']/@Gain">
		<xsl:choose>
			<xsl:when test="$CHANNEL='blue' and ../../../../../../@BlockID=$BLOCKID">
				<xsl:attribute name="Gain">
					<xsl:value-of select="$GAIN"/>
				</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="Gain">
					<xsl:value-of select="."/>
				</xsl:attribute>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Yellow -->
	<xsl:template match="Configuration/LDM_Block_Sequence/LDM_Block_Sequence_Block_List/LDM_Block_Sequence_Block/LDM_Block_Sequential/LDM_Block_Sequential_List/ATLConfocalSettingDefinition[2]/DetectorList/Detector[@Channel='2']/@Gain">
		<xsl:choose>
			<xsl:when test="$CHANNEL='yellow' and ../../../../../../@BlockID=$BLOCKID">
				<xsl:attribute name="Gain">
					<xsl:value-of select="$GAIN"/>
				</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="Gain">
					<xsl:value-of select="."/>
				</xsl:attribute>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Red -->
	<xsl:template match="Configuration/LDM_Block_Sequence/LDM_Block_Sequence_Block_List/LDM_Block_Sequence_Block/LDM_Block_Sequential/LDM_Block_Sequential_List/ATLConfocalSettingDefinition[3]/DetectorList/Detector[@Channel='2']/@Gain">
		<xsl:choose>
			<xsl:when test="$CHANNEL='red' and ../../../../../../@BlockID=$BLOCKID">
				<xsl:attribute name="Gain">
					<xsl:value-of select="$GAIN"/>
				</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="Gain">
					<xsl:value-of select="."/>
				</xsl:attribute>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>

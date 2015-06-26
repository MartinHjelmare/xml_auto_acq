<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output indent="no" method="text"/>
	
	<xsl:param name="TYPE" select="'0'"/>
	<xsl:param name="ZPOS" select="'0'"/>
	<xsl:param name="GAIN" select="'0'"/>
	<xsl:param name="BLOCKID" select="'0'"/>
	<xsl:param name="ELEMENTID" select="'0'"/>
	<xsl:param name="BLOCKNAME" select="'0'"/>
	<xsl:param name="USNAME" select="'0'"/>

	
	<xsl:template match="/">
		<xsl:choose>
		<!-- Zpos -->	
			<!-- AF job -->
			<xsl:when test="$TYPE='1' and $ZPOS='1'">
				<xsl:value-of select="Configuration/LDM_Block_Sequence/LDM_Block_Sequence_Block_List/LDM_Block_Sequence_Block/LDM_Block/ATLConfocalSettingDefinition/AdditionalZPositionList/AdditionalZPosition[@ZMode='2']/@ZPosition"/>
			</xsl:when>
			<!-- Master -->
			<xsl:when test="$TYPE='2' and $ZPOS='1'">
				<xsl:value-of select="Configuration/LDM_Block_Sequence/LDM_Block_Sequence_Block_List/LDM_Block_Sequence_Block/LDM_Block_Sequential/LDM_Block_Sequential_Master/ATLConfocalSettingDefinition/AdditionalZPositionList/AdditionalZPosition[@ZMode='2']/@ZPosition"/>
			</xsl:when>
			<!-- Sequential -->
			<xsl:when test="$TYPE='3' and $ZPOS='1'">
				<xsl:value-of select="Configuration/LDM_Block_Sequence/LDM_Block_Sequence_Block_List/LDM_Block_Sequence_Block/LDM_Block_Sequential/LDM_Block_Sequential_List/ATLConfocalSettingDefinition[1]/AdditionalZPositionList/AdditionalZPosition[@ZMode='2']/@ZPosition"/>
			</xsl:when>
		<!-- Gain -->
			<!-- AF job -->
			<xsl:when test="$GAIN='1'">
				<xsl:value-of select="Configuration/LDM_Block_Sequence/LDM_Block_Sequence_Block_List/LDM_Block_Sequence_Block/LDM_Block/ATLConfocalSettingDefinition/DetectorList/Detector[@Channel='2']/@Gain"/>
			</xsl:when>
			<!-- Gain job -->
			<xsl:when test="$GAIN='2'">
				<xsl:text>gain</xsl:text><!-- header -->
				<xsl:text>&#xa;</xsl:text><!-- new line -->
				<xsl:for-each select="Configuration/LDM_Block_Sequence/LDM_Block_Sequence_Block_List/LDM_Block_Sequence_Block/LDM_Block_Sequential/LDM_Block_Sequential_List/ATLConfocalSettingDefinition/DetectorList/Detector[@IsActive='1']">
					<xsl:value-of select="@Gain"/>
					<xsl:text>&#xa;</xsl:text><!-- new line -->
				</xsl:for-each>
			</xsl:when>
		<!-- BlockID -->
			<xsl:when test="$BLOCKID='1'">
				<xsl:text>blockid</xsl:text><!-- header -->
				<xsl:text>&#xa;</xsl:text><!-- new line -->
				<xsl:for-each select="Configuration/LDM_Block_Sequence/LDM_Block_Sequence_Block_List/LDM_Block_Sequence_Block">
					<xsl:value-of select="@BlockID"/>
					<xsl:text>&#xa;</xsl:text><!-- new line -->
				</xsl:for-each>
			</xsl:when>
		<!-- ElementID -->	
			<xsl:when test="$ELEMENTID='1'">
				<xsl:text>elementid</xsl:text><!-- header -->
				<xsl:text>&#xa;</xsl:text><!-- new line -->
				<xsl:for-each select="Configuration/LDM_Block_Sequence/LDM_Block_Sequence_Element_List/LDM_Block_Sequence_Element">
					<xsl:value-of select="@ElementID"/>
					<xsl:text>&#xa;</xsl:text><!-- new line -->
				</xsl:for-each>
			</xsl:when>
		<!-- BlockName -->
			<xsl:when test="$BLOCKNAME='1'">
				<xsl:text>blockname</xsl:text><!-- header -->
				<xsl:text>&#xa;</xsl:text><!-- new line -->
				<xsl:for-each select="Configuration/LDM_Block_Sequence/LDM_Block_Sequence_Block_List/LDM_Block_Sequence_Block/LDM_Block_Sequential">
					<xsl:value-of select="@BlockName"/>
					<xsl:text>&#xa;</xsl:text><!-- new line -->
				</xsl:for-each>
			</xsl:when>
		<!-- UserSettingName -->
		    <!-- Master -->
			<xsl:when test="$USNAME='1'">
				<xsl:text>usname_master</xsl:text><!-- header -->
				<xsl:text>&#xa;</xsl:text><!-- new line -->
				<xsl:for-each select="Configuration/LDM_Block_Sequence/LDM_Block_Sequence_Block_List/LDM_Block_Sequence_Block/LDM_Block_Sequential/LDM_Block_Sequential_Master/ATLConfocalSettingDefinition">
					<xsl:value-of select="@UserSettingName"/>
					<xsl:text>&#xa;</xsl:text><!-- new line -->
				</xsl:for-each>
			</xsl:when>
		    <!-- Sequential -->
			<xsl:when test="$USNAME='2'">
				<xsl:text>usname_seq</xsl:text><!-- header -->
				<xsl:text>&#xa;</xsl:text><!-- new line -->
				<xsl:for-each select="Configuration/LDM_Block_Sequence/LDM_Block_Sequence_Block_List/LDM_Block_Sequence_Block/LDM_Block_Sequential/LDM_Block_Sequential_List/ATLConfocalSettingDefinition">
					<xsl:value-of select="@UserSettingName"/>
					<xsl:text>&#xa;</xsl:text><!-- new line -->
				</xsl:for-each>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>

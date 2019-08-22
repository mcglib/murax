# -*- coding: utf-8 -*-

import csv
import datetime
import string
import sys
import xml.etree.ElementTree as ET

import requests

from thesis_functions import *


###################
#    Main Code
###################

# I did: file 1, 2, 3

reload(sys)
sys.setdefaultencoding('utf8')

pidArray = sys.argv[1:]

facultyDepartmentCodesDictionary= {}
transfertoFacultyDictionary(facultyDepartmentCodesDictionary)

languageIsoCodesDictionary= {}
transfertoDictionary(languageIsoCodesDictionary, "languageCode_Dictionary.txt")

monthsDictionary= {}
transfertoDictionary(monthsDictionary, "month_Dictionary.txt")

degreeDictionary= {}
transfertoDegreeDisciplineDictionary(degreeDictionary, "degree_Dictionary.txt")

disciplineDictionary= {}
transfertoDegreeDisciplineDictionary(disciplineDictionary, "discipline_Dictionary.txt")

if len(pidArray) > 0:

    nSpaces = {"dc": "http://purl.org/dc/elements/1.1/", "dcterms": "http://purl.org/dc/terms/"}

    for currentPid in pidArray:
        #print(currentPid)

        currentUrl = queryBuilder(currentPid)
        queryOutput = callQuery(currentUrl)
        root = ET.fromstring(queryOutput)

        for field in root.findall("mds/md[name='descriptive']") :
            for valueField in field.findall("value"):
                # Find the root element of the Descriptive Metadata XML (embedded in the general XML)
                recordRoot = ET.fromstring(valueField.text)

                # All required fields (Alphabetical order):
                # Clean up Date Field
                if isFieldEmpty(recordRoot.find("dc:date", namespaces= nSpaces), currentPid) is False:
                    for date in recordRoot.findall("dc:date", namespaces= nSpaces):
                        if date.text not in [None, "YYYY"]:
                            cleanedDate = removePunctuationField(date.text)
                            formattedDate = cleanDateField(cleanedDate, monthsDictionary)
                            date.text = formattedDate

                # Clean up Rights Field
                if isFieldEmpty(recordRoot.find("dc:rights", namespaces= nSpaces), currentPid) is False:
                    # Cleans and adds the generic rights statement.
                    cleanRightsField(recordRoot, nSpaces)

                # Clean up Title Field
                if isFieldEmpty(recordRoot.find("dc:title", namespaces= nSpaces), currentPid) is False:
                    for title in recordRoot.findall("dc:title", namespaces= nSpaces):
                        if title.text is not None:
                            cleanedTitle = cleanTitleField(title.text)
                            title.text = cleanedTitle

                # Clean up Type Field
                if isFieldEmpty(recordRoot.find("dc:type", namespaces= nSpaces), currentPid) is False:
                    for type in recordRoot.findall("dc:type", namespaces= nSpaces):
                        type.text = "Thesis"
                else:
                    typeField = ET.SubElement(recordRoot, "dc:type")
                    typeField.text = "Thesis"


            # Other Fields (Alphabetical Order)
                # Clean up Contributor Field
                for contributor in recordRoot.findall("dc:contributor", namespaces= nSpaces):
                    if isTheContributorFieldEmpty(contributor.text) is True:
                        recordRoot.remove(contributor)
                # Clean up Department Field
                for department in recordRoot.findall("dcterms:localdepartmentcode", namespaces= nSpaces):
                    if department.text is not None:
                        departmentCode = department.text
                        if departmentCode in facultyDepartmentCodesDictionary:
                            departmentLabel = facultyDepartmentCodesDictionary[departmentCode]
                            department.text = departmentLabel

                #Clean up Discipline Field
                for discipline in recordRoot.findall("dcterms:localthesisdegreediscipline", namespaces= nSpaces):
                    if discipline.text is not None:
                        cleanedDiscipline = cleanString(discipline.text)
                        cleanedDiscipline = correctDegreeDiscipline(cleanedDiscipline, disciplineDictionary)
                        discipline.text = cleanedDiscipline
                #Clean Degree Field
                for degree in recordRoot.findall("dcterms:localthesisdegreename", namespaces= nSpaces):
                    if degree.text is not None:
                        cleanedDegree = cleanString(degree.text)
                        cleanedDegree = correctDegreeDiscipline(cleanedDegree, degreeDictionary)
                        degree.text = cleanedDegree
                # Clean up extent field (Delete extent field (which has file size) and add extent field with pages numbers if it is necessary)
                for extent in recordRoot.findall("dcterms:extent", namespaces = nSpaces):
                    recordRoot.remove(extent)
                for extent in recordRoot.findall("dc:extent", namespaces = nSpaces):
                    recordRoot.remove(extent)
                for pageCount in recordRoot.findall("dcterms:localdisspagecount", namespaces = nSpaces):
                    if pageCount.text != "":
                        extentField = ET.SubElement(recordRoot, "dcterms:extent")
                        extentField.text = pageCount.text + " pages"
                # Clean up Faculty Field
                for faculty in recordRoot.findall("dcterms:localfacultycode", namespaces= nSpaces):
                    if faculty.text is not None:
                        facultyCode = faculty.text
                        if facultyCode in facultyDepartmentCodesDictionary:
                            facultyLabel = facultyDepartmentCodesDictionary[facultyCode]
                            faculty.text = facultyLabel
                # Add Institution information if missing
                if recordRoot.find("dcterms:localdissertationinstitution", namespaces= nSpaces) is None:
                    institutionField = ET.SubElement(recordRoot, "dcterms:localdissertationinstitution")
                    institutionField.text = "McGill University"
                # Clean up Language Field
                for language in recordRoot.findall("dc:language", namespaces= nSpaces):
                    if language.text is not None:
                        langIso = mapToRightLanguageCode(language.text, languageIsoCodesDictionary)
                        language.text = langIso
                #Clean up Publisher Field
                for publisher in recordRoot.findall("dc:publisher", namespaces=nSpaces):
                    if publisher.text is not None:
                        cleanedPublisherArray = cleanPublisher(publisher.text, facultyDepartmentCodesDictionary)
                        if len(cleanedPublisherArray) == 1:
                            publisher.text = cleanedPublisherArray[0]
                        else:
                            publisher.text = cleanedPublisherArray[0]
                            addedDisciplineField = ET.SubElement(recordRoot, "dcterms:localthesisdegreediscipline")
                            addedDisciplineField.text = cleanedPublisherArray[1]
                # Clean up Relation Field
                if recordRoot.find("dc:relation", namespaces=nSpaces) is None:
                    relationField = ET.SubElement(recordRoot, "dc:relation")
                    relationField.text = "Pid: " + currentPid
                else:
                    pidAdded = False
                    for relationField in recordRoot.findall("dc:relation", namespaces= nSpaces):
                        if relationField.text is None:
                            relationField = ET.SubElement(recordRoot, "dc:relation")
                            relationField.text = "Pid: " + currentPid
                            pidAdded = True
                        else:
                            currentId = cleanUpCurrentID(relationField.text)
                            if currentId != "":
                                relationField.text = "Pid: " + currentPid + " " + currentId
                                pidAdded = True
                            else:
                                recordRoot.remove(relationField)
                        if pidAdded == False:
                            relationField = ET.SubElement(recordRoot, "dc:relation")
                            relationField.text = "Pid: " + currentPid

                # Add "Department not identified" if there are no department and discipline codes.
                if recordRoot.find("dcterms:localdepartmentcode", namespaces= nSpaces) is None and recordRoot.find("dcterms:localthesisdegreediscipline", namespaces= nSpaces) is None:
                    addedDisciplineField = ET.SubElement(recordRoot, "dcterms:localthesisdegreediscipline")
                    addedDisciplineField.text = "Department not identified"

                ET.dump(recordRoot)

else:
    print("Add the record pids as arguments to the script")

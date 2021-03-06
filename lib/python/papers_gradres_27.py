# -*- coding: utf-8 -*-

import csv
import datetime
import string
import sys
import xml.etree.ElementTree as ET

import requests

#from reports_27_functions import transfertoDictionary, transfertoFacultyDictionary, removePunctuationField, readTextFile, queryBuilder, callQuery, cleanTitleField, cleanDateField, isTheContributorFieldEmpty, mapToRightLanguageCode, cleanUpCurrentID, cleanDisciplineField, cleanPublisher,transfertoDegreeDisciplineDictionary
from papers_gradres_27_functions import *


###################
#    Main Code
###################


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

myErrorFile = open("errorFile.txt", "w")

if len(pidArray) > 0:

    nSpaces = {"dc": "http://purl.org/dc/elements/1.1/", "dcterms": "http://purl.org/dc/terms/", "dcterms2" : "http://purl.org/dc/terms"}

    for currentPid in pidArray:
        #print(currentPid)

        currentUrl = queryBuilder(currentPid)
        queryOutput = callQuery(currentUrl)
        root = ET.fromstring(queryOutput)

        # Check if the Pid has multiple set of descriptive metadata

        array = root.findall("mds/md[name='descriptive']")

        for field in root.findall("mds/md[name='descriptive']") :
            for valueField in field.findall("value"):
                # Find the root element of the Descriptive Metadata XML (embedded in the general XML)
                recordRoot = ET.fromstring(valueField.text)

            # All required fields (Alphabetical order):

                # Clean up Date Field
                if isFieldEmpty(recordRoot.find("dc:date", namespaces= nSpaces)) is False:
                    for date in recordRoot.findall("dc:date", namespaces= nSpaces):
                        if date.text not in [None, "YYYY"]:
                            cleanedDate = removePunctuationField(date.text)
                            formattedDate = cleanDateField(cleanedDate, monthsDictionary)
                            date.text = formattedDate

                # Clean up Rights Field
                if isFieldEmpty(recordRoot.find("dc:rights", namespaces= nSpaces)) is False:
                    # Cleans and adds the generic rights statement.
                    cleanRightsField(recordRoot, nSpaces)

                # Clean up Title Field
                if isFieldEmpty(recordRoot.find("dc:title", namespaces= nSpaces)) is False:
                    for title in recordRoot.findall("dc:title", namespaces= nSpaces):
                        if title.text is not None:
                            cleanedTitle = cleanTitleField(title.text)
                            title.text = cleanedTitle

                # Clean up Type Field #Status is not necessary for gradres.
                if isFieldEmpty(recordRoot.find("dc:type", namespaces= nSpaces)) is False:
                    for type in recordRoot.findall("dc:type", namespaces= nSpaces):
                        type.text = "Paper"
                else:
                    typeField = ET.SubElement(recordRoot, "{http://purl.org/dc/elements/1.1/}type")
                    typeField.text = "Paper"


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
                #Clean up Discipline Field (Gradres2 namespace)
                for discipline in recordRoot.findall("dcterms2:localthesisdegreediscipline", namespaces= nSpaces):
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
                        extentField = ET.SubElement(recordRoot, "{http://purl.org/dc/terms/}extent")
                        extentField.text = pageCount.text + " pages"
                # Clean up Faculty Field
                for faculty in recordRoot.findall("dcterms:localfacultycode", namespaces= nSpaces):
                    if faculty.text is not None:
                        facultyCode = faculty.text
                        if facultyCode in facultyDepartmentCodesDictionary:
                            facultyLabel = facultyDepartmentCodesDictionary[facultyCode]
                            faculty.text = facultyLabel
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
                            addedDisciplineField = ET.SubElement(recordRoot, "{http://purl.org/dc/terms/}localthesisdegreediscipline")
                            addedDisciplineField.text = cleanedPublisherArray[1]
               # Clean up Relation Field
                if recordRoot.find("dc:relation", namespaces=nSpaces) is None:
                    relationField = ET.SubElement(recordRoot, "{http://purl.org/dc/elements/1.1/}relation")
                    relationField.text = "Pid: " + currentPid
                else:
                    pidAdded = False
                    for relationField in recordRoot.findall("dc:relation", namespaces= nSpaces):
                        if relationField.text is None:
                            relationField = ET.SubElement(recordRoot, "{http://purl.org/dc/elements/1.1/}relation")
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
                            relationField = ET.SubElement(recordRoot, "{http://purl.org/dc/elements/1.1/}relation")
                            relationField.text = "Pid: " + currentPid
                # Clean up Subject Field
                for subject in recordRoot.findall("dc:subject", namespaces=nSpaces):
                  if subject.text is not None:
                     subject.text = subject.text.strip('.')

                # Add "Department not identified" if there are no department and discipline codes.
                if recordRoot.find("dcterms:localdepartmentcode", namespaces= nSpaces) is None and recordRoot.find("dcterms:localthesisdegreediscipline", namespaces= nSpaces) is None and recordRoot.find("dcterms2:localthesisdegreediscipline", namespaces= nSpaces) is None:
                    addedDisciplineField = ET.SubElement(recordRoot, "{http://purl.org/dc/terms/}localthesisdegreediscipline")
                    addedDisciplineField.text = "Department not identified"

                ET.dump(recordRoot)

else:
    print("Add the record pids as arguments to the script")

# -*- coding: utf-8 -*-

import csv
import datetime
import string
import sys
import xml.etree.ElementTree as ET

import requests

###################
#    Functions
###################

def readTextFile(fileName):
    myFile = open(fileName, "r")
    reader = myFile.read()

    return reader

def transfertoDictionary(myDict):

    reader = readTextFile("FacultyDepartCode_Dictionary.txt")
    reader = reader.split("\n")
    for line in reader:
        key = line[:5].strip()
        value = line[6:].strip()
        myDict[key] = value


def queryBuilder(currentPid):
    coreUrl = "http://internal.library.mcgill.ca/digitool-reports/diverse-queries/hyrax/get-de-with-relations-by-pid.php?pid="
    parameters = "&return=xml"
    url = coreUrl + currentPid + parameters
    return url

def callQuery(myUrl):
    response = requests.get(myUrl)
    output = response.content.decode("utf-8")
    return output

def cleanTitleField(myTitleString):
    """ This function cleans up the title string by:
     - Removing square brackets (and double square brackets) from the title string - which was a digitool convention.
     - Removing extra whitespaces
    """

    # Remove extra spaces
    myTitleString = " ".join(myTitleString.split())

    firstChar = myTitleString[0]
    secondChar = myTitleString[1]

    # If there is a double [[]]
    if firstChar == "[" and secondChar == "[":
        cleanedTitle = myTitleString[2:]
        splitString = cleanedTitle.split(" ")
        firstWord = splitString[0]
        firstWord = firstWord[:-2]
        if firstWord[-1] == "'":
            cleanedTitle = firstWord + " ".join(splitString[1:])
        else:
            cleanedTitle = firstWord + " " + " ".join(splitString[1:])

    # If there is a single []
    elif firstChar == "[":
        cleanedTitle = myTitleString[1:]
        splitString = cleanedTitle.split(" ")
        firstWord = splitString[0]
        firstWord = firstWord[:-1]
        if firstWord[-1] == "'":
            cleanedTitle = firstWord + " ".join(splitString[1:])
        else:
            cleanedTitle = firstWord + " " + " ".join(splitString[1:])
    # If there are no []
    else:
        cleanedTitle = myTitleString

    return cleanedTitle

def removePunctuationDateField(myDateString):
    """ Remove final punctuation from the date field
    """
    lastChar = myDateString[-1]
    if lastChar in string.punctuation:
        cleanedDate = myDateString[:-1]
    else:
        cleanedDate = myDateString
    return cleanedDate

def dateToRightFormat(dateArray):
    """ Reformat the date field so it is always yyyy/mm/dd, or yyyy/mm or yyyy
    """
    for i in range(0, len(dateArray)):
        if dateArray[i] == "00":
            dateArray.pop(i)
        i = i + 1

    if len(dateArray) == 3 :
        if len(dateArray[0]) == 4:
            year = int(dateArray[0])
            month = int(dateArray[1])
            day = int(dateArray[2])

        elif len(dateArray[2]) == 4:
            year = int(dateArray[2])
            month = int(dateArray[1])
            day = int(dateArray[0])

        if day != 0 and day != 00:
            formatDate = datetime.date(year, month, day)
            formatDate = formatDate.strftime("%Y-%m-%d")

        else:
             formatDate = str(year) + "-" + str(month)

    elif len(dateArray) == 2:
        if len(dateArray[0]) == 4:
            year = dateArray[0]
            month = dateArray[1]

        elif len(dateArray[1]) == 4:
            year = dateArray[1]
            month = dateArray[0]

        formatDate = year + "-" + month

    return formatDate


def replaceAlphaNotationFromDate(myDateString):
    """ Replace alphabetical notation of date (January) with a numeric notation
    """
    monthDict = {"january": "01",
                "jan" : "01",
                "february": "02",
                "feb" : "02",
                "march": "03",
                "mar" : "03",
                "april": "04",
                "apr" : "04",
                "may": "05",
                "june": "06",
                "jun" : "06",
                "july": "07",
                "jul" : "07",
                "august": "08",
                "aug" : "08",
                "september": "09",
                "sept" : "09",
                "october": "10",
                "oct" : "10",
                "november": "11",
                "nov" : "11",
                "december": "12",
                "dec" : "12"}

    dateArray = myDateString.split(" ")
    for i in range (0, len(dateArray)):
        #Remove punctuation
        dateArray[i] = removePunctuationDateField(dateArray[i])

        #translate spelled out month
        if dateArray[i].isalpha():
            month = dateArray[i].lower()
            if month in monthDict:
                dateArray[i] = monthDict[month]
            else:
                print(dateArray)
                cleanDate = myDateString

    #reformat date
    cleanDate = dateToRightFormat(dateArray)

    return cleanDate

def cleanDateField(myDateString):
    """ This function sends different problematic dates (wrong format, wrong punctuation, has words, ...) to different cleaning up functions.
    """

    #print(myDateString)

    #See if there are any letters
    charFound = False
    i = 0
    while i in range(0, len(myDateString)) and not charFound:
        if myDateString[i].isalpha():
            charFound = True
        i = i + 1

    if charFound == True:
        formattedDate = replaceAlphaNotationFromDate(myDateString)

    elif "-" in myDateString:
        dateArray = myDateString.split("-")
        formattedDate = dateToRightFormat(dateArray)

    elif "/" in myDateString:
        dateArray = myDateString.split("/")
        formattedDate = dateToRightFormat(dateArray)

    else:
        formattedDate = myDateString

    #print(formattedDate)

    return formattedDate

def mapToRightLanguageCode(languageField):

    if languageField == "en":
        langIso = "eng"
    elif languageField == "fr":
        langIso = "fre"

    return langIso



###################
#    Main Code
###################
#reload(sys)
#sys.setdefaultencoding('utf8')


pidArray = sys.argv[1:]

facultyDepartmentCodesDictionary= {}
transfertoDictionary(facultyDepartmentCodesDictionary)


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

                # Clean up Title Field
                for title in recordRoot.findall("dc:title", namespaces= nSpaces):
                    cleanedTitle = cleanTitleField(title.text)
                    title.text = cleanedTitle
                # Clean up Date Field
                for date in recordRoot.findall("dc:date", namespaces= nSpaces):
                    cleanedDate = removePunctuationDateField(date.text)
                    formattedDate = cleanDateField(cleanedDate)
                    date.text = formattedDate
                # Clean up Language Field
                for language in recordRoot.findall("dc:language", namespaces= nSpaces):
                    langIso = mapToRightLanguageCode(language.text)
                    language.text = langIso
                # Clean up Faculty Field
                for faculty in recordRoot.findall("dcterms:localfacultycode", namespaces= nSpaces):
                    facultyCode = faculty.text
                    facultyLabel = facultyDepartmentCodesDictionary[facultyCode]
                    faculty.text = facultyLabel
                # Clean up Department Field
                for department in recordRoot.findall("dcterms:localdepartmentcode", namespaces= nSpaces):
                    departmentCode = department.text
                    departmentLabel = facultyDepartmentCodesDictionary[departmentCode]
                    department.text = departmentLabel
                # Clean up Type Field
                for type in recordRoot.findall("dc:type", namespaces= nSpaces):
                    type.text = "Report"
                # Clean up Relation Field
                if recordRoot.find("dc:relation", namespaces= nSpaces) is None:
                    relationField = ET.SubElement(recordRoot, "dc:relation")
                    relationField.text = "Pid:" + currentPid

                ET.dump(recordRoot)

else:
    print("Add the record pids as arguments to the script")

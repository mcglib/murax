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

# General Functions:

def readTextFile(fileName):
    myFile = open(fileName, "r")
    reader = myFile.read()

    return reader

def transfertoFacultyDictionary(myDict):

    reader = readTextFile("FacultyDepartCode_Dictionary.txt")
    reader = reader.split("\n")
    for line in reader:
        key = line[:5].strip()
        value = line[6:].strip()
        myDict[key] = value

def transfertoDictionary(myDict, myFilename):

    reader = readTextFile(myFilename)
    reader = reader.split("\n")
    for line in reader:
        key = line.split("\t")[0]
        value = line.split("\t")[1]
        myDict[key] = value

def removePunctuationField(myString):
    """ Remove final punctuation from the date field
    """
    lastChar = myString[-1]
    if lastChar in string.punctuation:
        cleanedString = myString[:-1]
    else:
        cleanedString = myString
    return cleanedString

# Query Digitool Functions:

def queryBuilder(currentPid):
    coreUrl = "http://internal.library.mcgill.ca/digitool-reports/diverse-queries/hyrax/get-de-with-relations-by-pid.php?pid="
    parameters = "&return=xml"
    url = coreUrl + currentPid + parameters
    return url

def callQuery(myUrl):
    response = requests.get(myUrl)
    output = response.content.decode("utf-8")
    return output

# Functions for required fields:
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

# Functions for date field:
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

def replaceAlphaNotationFromDate(myDateString, monthDict):
    """ Replace alphabetical notation of date (January) with a numeric notation
    """

    dateArray = myDateString.split(" ")
    for i in range (0, len(dateArray)):
        #Remove punctuation
        dateArray[i] = removePunctuationField(dateArray[i])

        #translate spelled out month
        if dateArray[i].isalpha():
            month = dateArray[i].lower()
            if month in monthDict:
                dateArray[i] = monthDict[month]
                #reformat date
                cleanDate = dateToRightFormat(dateArray)
            else:
                cleanDate = myDateString
        elif "X" in dateArray[i] :
            cleanDate = dateArray[i]   
        elif "u" in dateArray[i] :
            cleanDate = dateArray[i]  

    return cleanDate

def cleanDateField(myDateString, monthsDictionary):
    """ This function sends different problematic dates (wrong format, wrong punctuation, has words, ...) to different cleaning up functions.
    """
    
    #See if there are any letters
    charFound = False
    i = 0
    while i in range(0, len(myDateString)) and not charFound:
        if myDateString[i].isalpha():
            charFound = True
        i = i + 1
        
    if charFound == True:
        formattedDate = replaceAlphaNotationFromDate(myDateString, monthsDictionary)

    elif "-" in myDateString:
        dateArray = myDateString.split("-")
        formattedDate = dateToRightFormat(dateArray)

    elif "/" in myDateString:
        dateArray = myDateString.split("/")
        formattedDate = dateToRightFormat(dateArray)
    
    else:
        formattedDate = myDateString
    
    return formattedDate

# Functions about other fields: 
def isTheContributorFieldEmpty(contributorField):
    """ Remove field if it only has (Supervisor) written, which was the default text of the field.
    """
    if contributorField in [None, ""] :
        return True
    else:
        contributor = contributorField.strip()
        if contributor == "(Supervisor)":
            return True

def mapToRightLanguageCode(languageField):
    """ map the language codes to the right ISO 639 3 letter codes.
    """
    if languageField in languageIsoCodesDictionary:
        langIso = languageIsoCodesDictionary[languageField]
        
    return langIso

def cleanUpCurrentID(currentIdentifier):
    """ The relation field contains related identifier fields. The field should contain the OCLC number, the Proquest number, and the pid.
     This function cleans up the field if something is in the field, keeping proquest numbers and removing Aleph numbers.
     The result of the relation field should be: Proquest: nnnnn Pid: nnnnn OCLC: nnnnnn
    """
    currentIdentifier = currentIdentifier.strip()

    if currentIdentifier.isdigit():
        cleanedIdentifier = ""
    else:
        if "nnnn" in currentIdentifier.lower():
            cleanedIdentifier = ""
        elif currentIdentifier == "alephsysno:":
            cleanedIdentifier = ""
        else:
            identifierArray = currentIdentifier.split(" ")
            
            idNum = ""
            idType = ""
            for identifier in identifierArray:
                identifier = removePunctuationField(identifier)
                if identifier.isalpha():
                    if "proquest" in currentIdentifier.lower():
                        idType = "Proquest"
                else:
                    idNum = identifier
            
            if idType == "Proquest" and idNum != "":
                cleanedIdentifier = "Proquest: " + idNum 
            else:
                cleanedIdentifier = ""  
    return(cleanedIdentifier)

def cleanDisciplineField(currentDiscipline):
    """ Remove extra spaces and final punctuation from the discipline field.
    """

    discipline = currentDiscipline.strip()
    cleanedDiscipline = removePunctuationField(discipline)

    return cleanedDiscipline

def cleanPublisher(currentPublisher):
    """ Remove additional information from the publisher field that shouldn't be there. This function checks if there is more than "McGill University" entered. 
    For reports, the additional information is the departmental affiliation, which moves to another field
    """
    publisher = currentPublisher.strip()
    publisher = removePunctuationField(publisher)
    publisher = publisher.lower()
    if publisher == "mcgill university":
        myArray = [currentPublisher]
    else:
        myPubArray = currentPublisher.split(",")
        disciplineInfo =  myPubArray[0].strip()
        myArray = ["McGill University", disciplineInfo]
    return myArray

###################
#    Main Code   
###################

#reload(sys)  
#sys.setdefaultencoding('utf8')

pidArray = sys.argv[1:]

facultyDepartmentCodesDictionary= {}
transfertoFacultyDictionary(facultyDepartmentCodesDictionary)

languageIsoCodesDictionary= {}
transfertoDictionary(languageIsoCodesDictionary, "languageCode_Dictionary.txt")

monthsDictionary= {}
transfertoDictionary(monthsDictionary, "month_Dictionary.txt")


if len(pidArray) > 0:

    nSpaces = {"dc": "http://purl.org/dc/elements/1.1/", "dcterms": "http://purl.org/dc/terms/"}

    for currentPid in pidArray:

        currentUrl = queryBuilder(currentPid)
        queryOutput = callQuery(currentUrl)
        root = ET.fromstring(queryOutput)

        for field in root.findall("mds/md[name='descriptive']") :
            for valueField in field.findall("value"):
                # Find the root element of the Descriptive Metadata XML (embedded in the general XML)
                recordRoot = ET.fromstring(valueField.text)

            # All required fields (Alphabetical order):    
                # Clean up Date Field    
                for date in recordRoot.findall("dc:date", namespaces= nSpaces):
                    if date.text not in [None, "YYYY"]:
                        cleanedDate = removePunctuationField(date.text)
                        formattedDate = cleanDateField(cleanedDate, monthsDictionary)
                        date.text = formattedDate
                # Clean up Title Field
                for title in recordRoot.findall("dc:title", namespaces= nSpaces):
                    if title.text is not None:
                        cleanedTitle = cleanTitleField(title.text)
                        title.text = cleanedTitle
                # Clean up Type Field
                for type in recordRoot.findall("dc:type", namespaces= nSpaces):
                    type.text = "Report"
                
            
            # Other Fields (Alphabetical Order) 
                # Clean up Contributor Field
                for contributor in recordRoot.findall("dc:contributor", namespaces= nSpaces):
                    if isTheContributorFieldEmpty(contributor.text) is True:
                        recordRoot.remove(contributor)
                # Clean up Department Field
                for department in recordRoot.findall("dcterms:localdepartmentcode", namespaces= nSpaces):
                    if department.text is not None:
                        departmentCode = department.text
                        departmentLabel = facultyDepartmentCodesDictionary[departmentCode]
                        department.text = departmentLabel
                #Clean up Discipline Field
                for discipline in recordRoot.findall("dcterms:localthesisdegreediscipline", namespaces= nSpaces):
                    if discipline.text is not None:
                        cleanedDiscipline = cleanDisciplineField(discipline.text)
                        discipline.text = cleanedDiscipline
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
                        facultyLabel = facultyDepartmentCodesDictionary[facultyCode]
                        faculty.text = facultyLabel
                # Clean up Language Field
                for language in recordRoot.findall("dc:language", namespaces= nSpaces):
                    if language.text is not None:
                        langIso = mapToRightLanguageCode(language.text)
                        language.text = langIso
                #Clean up Publisher Field
                for publisher in recordRoot.findall("dc:publisher", namespaces=nSpaces):
                    if publisher.text is not None:
                        cleanedPublisherArray = cleanPublisher(publisher.text)
                        if len(cleanedPublisherArray) == 1:
                            publisher.text = cleanedPublisherArray[0]
                        else:
                            publisher.text = cleanedPublisherArray[0]
                            addedDisciplineField = ET.SubElement(recordRoot, "dcterms:localthesisdegreediscipline")
                            addedDisciplineField.text = cleanedPublisherArray[1]
                # Clean up Relation Field
                for relationField in recordRoot.findall("dc:relation", namespaces= nSpaces):
                    if relationField.text is None:
                        relationField = ET.SubElement(recordRoot, "dc:relation")
                        relationField.text = "Pid: " + currentPid
                    else:
                        currentId = cleanUpCurrentID(relationField.text)
                        relationField.text = "Pid: " + currentPid + " " + currentId
                
                ET.dump(recordRoot)

else:
    print("Add the record pids as arguments to the script")

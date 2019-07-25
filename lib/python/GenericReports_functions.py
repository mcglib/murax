# -*- coding: utf-8 -*-

import csv
import datetime
import re
import string
import sys
import xml.etree.ElementTree as ET

import requests


###################
#    Functions
###################

# General Functions:

def readTextFile(fileName):
    """ Function that read text files
    """
    myFile = open(fileName, "r")
    reader = myFile.read()

    return reader

def transfertoFacultyDictionary(myDict):
    """ Function that transform the faculty Department Code file into a dictionary
    """
    reader = readTextFile("FacultyDepartCode_Dictionary.txt")
    reader = reader.split("\n")
    for line in reader:
        key = line[:5].strip()
        value = line[6:].strip()
        myDict[key] = value

def transfertoDictionary(myDict, myFilename):
    """ Function that transform a file into a dictionary
    """
    reader = readTextFile(myFilename)
    reader = reader.split("\n")
    for line in reader:
        key = line.split("\t")[0]
        value = line.split("\t")[1]
        myDict[key] = value

def transfertoDegreeDisciplineDictionary(myDict, myFilename):
    """ Function that transform the degree and discipline files into a dictionary
    """
    reader = readTextFile(myFilename)
    reader = reader.split("\n")
    for line in reader:
        line = re.sub("[\t]*", "", line)
     
        lineArray = line.split("/")
        key = lineArray[0]
        value = lineArray[1]

        key = key.strip()
        value = value.strip()

        myDict[key] = value


def cleanString(currentString):
    """ Remove extra spaces and final punctuation from string.
    """

    cleanstring = currentString.strip()
    cleanerString = removePunctuationField(cleanstring)

    return cleanerString

def removePunctuationField(myString):
    """ Remove final punctuation from the date field
    """
    lastChar = myString[-1]
    if lastChar in string.punctuation:
        cleanedString = myString[:-1]
    else:
        cleanedString = myString
    return cleanedString

# Functions that query digitool
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

def replaceAlphaNotationFromDate(myDateString, monthDict, currentPid):
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

def cleanDateField(myDateString, monthsDictionary, currentPid):
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
        formattedDate = replaceAlphaNotationFromDate(myDateString, monthsDictionary, currentPid)

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

def mapToRightLanguageCode(languageField, languageIsoCodesDictionary):
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
    #cleanedIdentifier = currentIdentifier
    currentIdentifier = currentIdentifier.strip()

    if currentIdentifier.isdigit():
        cleanedIdentifier = ""
        #cleanedIdentifier = "Aleph: " + currentIdentifier
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

def correctDegreeDiscipline(currentString, dictionary):
    if currentString in dictionary:
        correctedString = dictionary[currentString]
    else:
        correctedString = currentString
    return correctedString
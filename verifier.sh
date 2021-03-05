#!/bin/bash

#set -x
EXPORTCSV=${EXPORTCSV:-1}
SILENT=${SILENT:-1}
TIMEOUT="timeout -s9 3s"

PASSED="\033[32;1mPASSED\033[0m"
FAILED="\033[31;1mFAILED\033[0m"

SUM="shasum -a 512 -p"
CSV="login;"
HDR="header;"

##. $PWD/chasse.sh

verifier_tar() {
    if [ ! -d "CarnetsDeVoyage" ]
    then
	echo """
Exercice 1: Mise en place de la chasse au trésor
  Petit echauffement. Vous devez extraire l'archive
  CarnetsDeVoyage.tar.gz dans le répertoire courant
"""
	return 1
    else
	return 0
    fi
}

printheader_exo2() {
    echo """
Objectif: Identifier le répertoire dans lequel se trouve la clé du trésor.

La clé du trésor est cachée au sein d'un des répertoires de l'archive
extraite. Chacun des répertoires correspond à un voyage, dont chacun
des noms a été construit sur le même modèle : <année>-<lieu>, associé
aux date et destination du voyage entrepris. Le champ <année> est
toujours constitué de quatre chiffres. Quant au champ <lieu>, il
correspond soit à un pays, et dans ce cas il commence par une
majuscule, soit à une ville et il commence par une minuscule. Les deux
champs sont séparés soit par un tiret haut, soit par un tiret bas.

La clé du trésor ayant été cachée lors d'un voyage itinérant à la fin
du siècle dernier, nous sommes à la recherche d'un répertoire dont la
date de création est comprise entre 1970 et 1999, et dont le lieu
référence un pays. Par exemple, 1986-Bolivie.

Afin de mener à bien la recherche de la clé du trésor, nous vous
proposons de procéder de manière incrémentale. Pour cela, vous allez
écrire un script nommé chasse.sh que vous modifierez à chaque étape.

Remarque: À chaque étape, pensez à vérifier que votre script est
correct en l'exécutant.  
"""
}

verifier_chasse() {
    local error=0
    if [ ! -x "chasse.sh" ]
    then
	error=1
    else
	head -n 1 chasse.sh | grep "^#!/" 2>&1 > /dev/null
	if [ $? -ne 0 ]
	then
	    error=2
	fi
    fi

    if [ $error -ne 0 ]
    then
    	printheader_exo2
    	echo """
Exercice 2a:
   Commencez par créer un script shell chasse.sh avec l'entête
   nécéssaire pour un script, ainsi que les bons droits
"""
    fi
    return $error
}

verifier_base() {
    local error=0
    if [ -z "$base" ]
    then
	error=1
    else
	if [ "$base" != "CarnetsDeVoyage" ]
	then
	    error=2
	fi
    fi

    if [ $error -ne 0 ]
    then
    	printheader_exo2
    	echo """
Exercice 2b:
   Définissez une variable nommée base dans votre script et affectez lui
   le chemin CarnetsDeVoyage.
"""
    fi
    return $error
}

verifier_motif() {
    local error=0
    local frc=5
    type filtrage > /dev/null 2>&1 
    if [ $? -ne 0 ]
    then
	echo "La fonction verifier_modif n'est pas définie"
	error=1
    else
	local answer=$( filtrage  )
	if [ -z "$answer" ]
	then
	    echo "La fonction verifier_modif n'a rien retourné"
	    error=3
	else
	for ans in $answer
	do
	    local rc=5
	    local str=""
	    echo $ans | grep "$base/19[7-9][0-9][-_][A-Z].*" > /dev/null 2>&1
	    if [ $? -ne 0 ]
	    then
		str="$ans ne respecte pas la regle 5"
		rc=4
	    fi
	    echo $ans | grep "$base/19[7-9][0-9][-_].*" > /dev/null 2>&1
	    if [ $? -ne 0 ]
	    then
		str="$ans ne respecte pas la regle 4"
		rc=3
	    fi
	    echo $ans | grep "$base/19[7-9][0-9].*" > /dev/null 2>&1
	    if [ $? -ne 0 ]
	    then
		str="$ans ne respecte pas la regle 3"
		rc=2
	    fi
	    echo $ans | grep "$base/19[7-9].*" > /dev/null 2>&1
	    if [ $? -ne 0 ]
	    then
		str="$ans ne respecte pas la regle 2"
		rc=1
	    fi
	    echo $ans | grep "$base/19.*" > /dev/null 2>&1
	    if [ $? -ne 0 ]
	    then
		str="$ans ne respecte pas la regle 1"
		rc=0
	    fi

	    if [ $rc -lt $frc ]
	    then
		frc=$rc
	    fi

	    if [ ! -z "$str" ]
	    then
		echo $str
	    fi
	done
	if [ $frc -ne 5 ]
	then
	    error=2
	fi
	fi
    fi

    if [ $error -ne 0 ]
    then
    	printheader_exo2
    	echo """
Exercice 2c:
  Votre script doit maintenant sélectionner tous les fichiers qui
  correspondent à des voyages en utilisant des motifs de filtrage
  bash. Pour cela, votre script doit définir une fonction:

filtrage() {
}

  qui ne prend pas d'arguments et qui retourne la liste des
  répertoires correspondant aux critères correspondant à la
  recherche les uns derrière les autres.

  On procédera par étape pour simplifier le problème pour retourner:
   1- tous les fichiers dont le nom commence par 19 se trouvant dans
      le répertoire $base
   2- tous les fichiers dont le nom commence par 19 et est suivi par
      un chiffre entre 7 et 9,
   3- tous les fichiers dont le nom commence par 19, est suivi par un
      chiffre entre 7 et 9, et est suivi d'un chiffre quelconque,
   4- tous les fichiers dont le nom commence par 19, est suivi par un
      chiffre entre 7 et 9, est suivi d'un chiffre quelconque, et est
      suivi soit par un tiret bas soit par un tiret haut.
   5- tous les fichiers dont le nom commence par 19, est suivi par un
      chiffre entre 7 et 9, est suivi d'un chiffre quelconque, est suivi
      soit par un tiret bas soit par un tiret haut, et est suivi d'une
      chaîne de caractères quelconque dont la première lettre est une
      majuscule (On utilisera [[:upper:]] pour la majuscule).

Pour vous aider, vous devriez écrire une commande du type

Remarque: Vérifiez manuellement que les entrées sélectionnées
correspondent bien aux descriptions données, en appelant la fonction
dans votre script. On rappelle qu'une fonction s'appelle tout
simplement en donnant son nom. Mettre à la fin de son script:

filtrage

Error($error)
"""
	if [ $error -eq 2 ]
	then
	    echo "Ok jusqu'à l'étape $frc"
	fi
    fi
    return $error
}

verifier_repertoire() {
    local error=0
    type identify_rep > /dev/null 2>&1 
    if [ $? -ne 0 ]
    then
	error=1
    else
	selection=$( filtrage )
	directory=$( identify_rep $selection )
	if [ -z "$directory" ]
	then
	    echo "La fonction n'affiche rien sur la sortie standard"
	    error=2
	else
	    if [ "$directory" != "CarnetsDeVoyage/1978-Senegal" ]
	    then
		echo "$directory n'est pas le bon répertoire"
		error=3
	    fi
	fi
    fi

    if [ $error -ne 0 ]
    then
    	printheader_exo2
    	echo """
Exercice 2d:
  À ce stade, il doit vous rester 4 entrées candidates car il n'y a eu
  aucun filtre sur le type des entrées considérées.

  Nous sommes à la recherche d'un plan d'itinéraire. Nous pouvons donc
  raffiner notre quête en nous limitant aux répertoires dans lequel le
  trésor aura possiblement été caché. Avant de vérifier si un fichier
  est un répertoire. Pour cela, ajouter dans votre script une fonction:

identify_rep() {
}

  Cette fonction prend en parametre une liste des noms trouvés
  précédemment et sera donc appelée de la façon suivante à la fin de votre script:
identify_rep \$( filtrage )
 
  Cette fonction doit d'abord itérer sur les noms trouvés à la question précédente.
  1- Commencez par essayer d'afficher *uniquement* les noms de
     repértoires avec echo dans une boucle.
  2- Modifiez le corps de la boucle de façon à n'afficher que les répertoires.
  3- Le voyage ayant été long, votre script doit sélectionner le
     répertoire le plus volumineux. Vous devez donc modifier votre
     boucle de façon à stocker, dans une nouvelle variable nommée rep,
     le répertoire le plus volumineux.
     Nous procédons en plusieurs étapes. Dans un premier temps,
     remplacez le echo de l'étape 1 de façon à afficher la taille de
     chacun des répertoires (sans les sous-répertoires). (cf la
     commande du)
  4- En utilisant un tube et la commande cut, n'affichez que la taille
     des répertoires (c.-à-d., sans leur nom).  5- Vous avez désormais
     toutes les informations nécéssaires pour ne stocker *que* le
     répertoire le plus gros dans la variable rep
  5- Affichez la valeur trouvée pour rep avec echo

Error($error)
"""
    fi
    return $error
}


printheader_exo3() {
    echo """
Exercice 3:
Objectif: Trouver le fichier qui sert de clé au trésor !

Pour identifier le fichier qui sert de clé, nous procédons étape par étape. 
"""
}

verifier_itinerary() {
    local error=0
    local frc=2
    type find_itineraries > /dev/null 2>&1 
    if [ $? -ne 0 ]
    then
	echo "La fonction find_itineraries n'existe pas"
	error=1
    else
	local selection=$( filtrage )
	local directory=$( identify_rep $selection | tail -n 1 )
	local itineraries=$( find_itineraries $directory )

	if [ -z "$itineraries" ]
	then
	    echo "La fonction find_itineraries n'a rien retourné"
	    error=3
	else
	for it in $itineraries
	do
	    local rc=2
	    if [ ! -f "$it" ]
	    then
	       echo "$it n'est pas un fichier régulier"
	       rc=1
	    fi
	    echo "$it" | grep "$base/.*Itineraire.*" > /dev/null 2>&1
	    if [ $? -ne 0 ]
	    then
	       echo "$it ne contient pas Itinéraire"
	       rc=0
	    fi

	    if [ $rc -lt $frc ]
	    then
		frc=$rc
	    fi
	done
	
	if [ $frc -ne 2 ]
	then
	    error=2
	fi
	fi
    fi

    if [ $error -ne 0 ]
    then
    	printheader_exo3
    	echo """
Exercice 3a: Commencez par étendre le script en ajoutant une fonction:

find_itineraries() {
}

qui prendra le répertoire trouvé précédemment en paramêtre. Mettez à la fin de votre script:

rep=$( identify_rep $( filtrage ) )
find_itineraries \$rep

Cette fonction ne sert QU'a afficher les *fichiers ordinaires* se
trouvant dans le répertoire passé en paramètre ou dans un de ses
sous-répertoires, et dont le nom contient 'Itineraire'

Remarque: Pour cette question on utilisera la fonction *find* avec les
bonnes options pour filtrer le type de fichier, et les noms.

Error($error)
"""
    fi
    return $error
}

verifier_itinerary2() {
    local error=0
    local frc=2
    type find_signature > /dev/null 2>&1 
    if [ $? -ne 0 ]
    then
	error=1
    else
	local selection=$( filtrage )
	local directory=$( identify_rep $selection | tail -n 1 )
	local itineraries=$( find_itineraries $directory )
	local file=$( find_signature $itineraries )

	if [ -z "$file" ]
	then
	    echo "find_signature n'a rien retourné"
	    error=2
	else
	    if [ "$file" != "CarnetsDeVoyage/1978-Senegal/Organisation/Itineraire.txt" ]
	    then
		echo "find_signature n'a pas retourné la bonne clé"
		error=3
	    fi
	fi
    fi

    if [ $error -ne 0 ]
    then
    	printheader_exo3
    	echo """
Exercice 3b: Parmi les fichiers trouvés précédemment, identifiez celui
qui contient la signature de Bilbon grâce à la commande grep dans la
fonction suivante:

find_signature() {
}

qui prendra les fichiers trouvés précédemment en paramêtre. Mettez à la fin de votre script:

rep=$( identify_rep $( filtrage ) )
find_signature \$( find_itineraries \$rep )

Cette fonction ne sert QU'a afficher les *fichiers ordinaires* de

Error($error)
"""
    fi
    return $error
}

verifier_key() {
    local error=0
    local frc=2
    type find_key > /dev/null 2>&1 
    if [ $? -ne 0 ]
    then
	error=1
    else
	local selection=$( filtrage )
	local directory=$( identify_rep $selection | tail -n 1 )
	local itineraries=$( find_itineraries $directory )
	local file=$( find_signature $itineraries )
	local key=$( find_key $file )

	tresor="CarnetsDeVoyage/2015-Seychelles/Mahe/Plages/relache"
	if [ -z "$key" ]
	then
	    str="No key has been returned"
	    error=5
	else
	    if [ "$key" != $tresor ]
	    then
		str="$key n'est pas le bon fichier. Désolé."
		error=5
	    fi
	fi

	if [ ! -f compact.txt  ]
	then
	    str="Le fichier compact.txt n'existe pas"
	    error=2
	else
	    rm -f  .compact.dat .compact.sol
	    grep -v "^\$" $file | sort -k 3 | cut -d ' ' -f 3 | head -n 2 >  .compact.sol
	    grep -v "^\$" $file | sort -k 3 | cut -d ' ' -f 3 | tail -n 2 >> .compact.sol
	    cut -d ' ' -f 3 compact.txt > .compact.dat

	    (diff -q .compact.dat .compact.sol)  > /dev/null 2>&1 
	    local rc=$?
    
	    if [ $rc -ne 0 ]
	    then
		str="compact.txt n'a pas le bon contenu"
		error=3
	    fi
	    rm -f  .compact.dat .compact.sol
	    
	    local nb=$( wc -l compact.txt | cut -f 1 -d ' ' )
	    if [ $nb -ne 4 ]
	    then
		str="compact.txt does not have the correct number of lines"
		error=4
	    fi
	fi

	if [ ! -f trie.txt  ]
	then
	    str="Le fichier trie.txt n'existe pas"
	    error=2
	else
	    rm -f  .tri.dat .tri.sol
	    grep -v "^\$" $file | sort -k 3 | cut -d' ' -f 3 > .tri.sol
	    cut -d ' ' -f 3 trie.txt > .tri.dat

	    (diff -q .tri.dat .tri.sol)  > /dev/null 2>&1 
	    local rc=$?
    
	    if [ $rc -ne 0 ]
	    then
		str="trie.txt n'est pas correctement trié"
		error=3
	    fi
	    rm -f  .tri.dat .tri.sol
	    
	    grep "^\$" trie.txt > /dev/null 2>&1
	    if [ $? -eq 0 ]
	    then
		str="trie.txt a des lignes vides"
		error=3
	    fi
	fi

    	if [ ! -z "$str" ]
	then
	    echo $str
	fi
    fi

    if [ $error -ne 0 ]
    then
    	echo """
Exercice 4: On y est presque !!!
Pour rappel, la recherche disait: « ... extraire les 3e mots des
couples de lignes de tête et de queue de fichier ... ». Pour réussir à
résoudre cette partie de l'énigme, nous vous proposons de travailler
par étape dans une fonction:

find_key() {
}

qui prendra le fichier trouvé précédemment en paramêtre. Mettez à la fin de votre script:

rep=$( identify_rep $( filtrage ) | tail -n 1 )
itineraries=\$( find_itineraries \$rep )
file=\$( find_signature \$itineraries )
find_key \$file

Les étapes à suivre sont donc:
    1- Triez les lignes du fichier selon le 3ème mot
    2- Supprimez les lignes vides du résultat précédent et stocker le résultat dans le fichier trie.txt
    2- Isolez les deux premières lignes du fichier trie.txt et stocker les dans compact.txt
    3- Isolez les deux dernières lignes du fichier trie.txt et ajouter les dans compact.txt
    4- Ne conservez que les troisièmes mots de chacune des lignes du fichier compact.txt
    5- Concaténez les 4 mots trouvés en les séparant par le caractère / et affichez le résultat
           => Vous avez trouvez le trésor

ERROR($error)
"""
    else
	cat $key
    fi
    return $error
}


verifier_tar
if [ $? -ne 0 ]
then
    exit 0
fi

echo "Step 1: Ok [tar]"

verifier_chasse
if [ $? -ne 0 ]
then
    exit 0
fi

echo "Step 2: Ok [chasse.sh]"

. chasse.sh > /dev/null 2>&1 

verifier_base
if [ $? -ne 0 ]
then
    exit 0
fi

echo "Step 3: Ok [variable]"

verifier_motif
if [ $? -ne 0 ]
then
    exit 0
fi

echo "Step 4: Ok [motif]"

verifier_repertoire
if [ $? -ne 0 ]
then
    exit 0
fi

echo "Step 5: Ok [find_rep]"

verifier_itinerary
if [ $? -ne 0 ]
then
    exit 0
fi

echo "Step 6: Ok [find_files]"

verifier_itinerary2
if [ $? -ne 0 ]
then
    exit 0
fi

echo "Step 7: Ok [find_signature]"

verifier_key
if [ $? -ne 0 ]
then
    exit 0
fi

echo "Step 8: Ok [find_diamond]"

echo "Bravo ! Vous avez découvert le trésor !!! Pensez à sauvegrader votre script :)"

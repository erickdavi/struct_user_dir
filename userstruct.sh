#!/bin/bash

#Maintainer: Erick Davi Morgade Pessanha
#Subject: Realiza a criação de usuários, grupos e diretórios e atribui permissão conforme arquivo csv de modelo.
#O formato do arquivo csv:
#group,user,directory



WORKFILE="usergroups.csv"


#Remove a estrutura aplicada nesse exercício
function rm_old_struct(){
  #Remove todos os usuários não sistemicos pré-existentes e seus respectivos diretórios $HOME
  #getent passwd | awk -F: '{if ($3 >= 1000){printf("userdel -r %s\n",$2)}}'
  awk -F, '{if($2 != "root"){printf "userdel -r %s\n",$2}}' $WORKFILE
  awk -F, '{if($1 !="root"){printf "groupdel %s\n",$1}}' $WORKFILE | uniq
  awk -F, '{printf "rm -rf %s\n",$3}' $WORKFILE | uniq
  

}

#Realiza a criação dos usuários e grupos
function create_user_group(){
  #Realiza a criação dos grupos de usuários
  awk -F, '{if($1 !="root"){printf "groupadd %s\n",$1}}' $WORKFILE | uniq

  #Realiza a criação dos usuários inserindo-os em seus grupos suplementares
  awk -F, '{if($2 != "root"){printf "useradd %s -G %s\n",$2,$1}}' $WORKFILE
}

#Realiza a criação dos diretórios e atribui propriedade e permissão conforme o enunciado do exercício
function create_dir(){
  #Realiza a criação dos diretórios de trabalho
  awk -F, '{printf "mkdir -p %s\n",$3}' $WORKFILE | uniq

  #Atribui o grupo dono de cada um dos diretórios
  awk -F, '{printf "chown root.%s %s\n",$1,$3}' $WORKFILE | uniq

  #Realiza o ajuste das permissões desejadas nos diretórios
  awk -F, '{if ($3 !="/publico"){printf "chmod 770 %s\n",$3}else{printf "chmod 777 %s\n",$3}}' $WORKFILE | uniq
}
function main(){
  rm_old_struct
  create_user_group
  create_dir
}
main  
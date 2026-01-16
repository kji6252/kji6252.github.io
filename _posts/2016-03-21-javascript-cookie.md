---
title: 자바스크립트 쿠키 간단 사용법
layout: post
date: 2016-03-21 10:54:00
categories:
  - 자바스크립트
tags:
  - Javascript
  - Cookie
---
# 개요

쿠키를 사용할일이 있어 공부를 하다가 정리 할겸 블로그에 작성 합니다.  
document.cookie 를 자바스크립트 콘솔에 입력하면 해당 도메인의 쿠키값들이 나옵니다.  
문자열형태로 나오며 "키=벨유; 키=벨유; 키=벨유" 형식으로 존재합니다.

W3Schools를 보고 참조 하였습니다.  
[http://www.w3schools.com/js/js_cookies.asp](http://www.w3schools.com/js/js_cookies.asp)

쿠키값은 총 3개의 파라미터로 구성되며

* 키=벨유 : MAP형식으로 키와 벨유를 저장
* expires=Date타입값 : 쿠키 제한 시간을 정함
* path:쿠키 생성 위치 : 쿠키 생성 위치를 지정
<!-- more -->
편안하게 cookie플러그인을 사용하면 좋겠지만 간단하게 작성하는법에 대해 설명해 보겠습니다.

# 쿠키 생성
-----

```javascript
var valueDate = new Date();

//Date를 활용하여 원하는 쿠키유지시간 조절 가능
valueDate.setDate(valueDate.getDate()+추가값);
valueDate.setHours(valueDate.getHours()+추가값);
valueDate.setMinutes(valueDate.getMinutes()+추가값);
valueDate.setSeconds(valueDate.getSeconds()+추가값);

document.cookie = 'username=John Doe; expires='+valueDate.toGMTString()+'; path=/';
```

Date값을 활용하여 원하는 시간쿠키를 유지하는게 가능합니다.

# 쿠키 삭제

```javascript
//간단하게 new Date(0)을 넣어서 쿠키값을 삭제
document.cookie = 'username=John Doe; expires='+new Date(0).toGMTString()+'; path=/';
```

쿠키는 유지기간보다 낮으면 되므로 간단하게 new Date(0)을 넣어 처리 하면 삭제 됩니다.

# 쿠키 검색

```javascript
document.cookie.indexOf('찾을쿠키명') > -1
```

쿠키도 문자열로 되어있기 때문에 문자열 탐색에 쓰이는 함수를 똑같이 사용  
-1이면 없음 0이상으면 해당 문자열의 첫번째 자리값 반환

# 쿠키 값 얻어오기

```javascript
var cookie = document.cookie;
var startIndexOf = cookie.indexOf('찾을쿠키명 ');
var endIndexOf = cookie.indexOf(';',startIndexOf);
if(endIndexOf == -1)endIndexOf = cookie.length; //맨끝일경우;가 없으므로 맨마지막자리를 가져온다.
cookie.substring(startIndexOf+'찾을쿠키명='.length, endIndexOf);
```

값을 가져 와서 쿠키값을 활용하면 될거 같습니다.

# 쿠키값 활용 예제

하루 동안의 방문 횟수를 증가 시키는 로직을 짜보았습니다.

```javascript
var cookie = document.cookie;
var cookieName = 'VISIT_COUNT';
var cookieNameIndexOf = cookie.indexOf(cookieName);

var toDay = new Date();
toDay.setHours(24);
toDay.setMinutes(0);
toDay.setSeconds(0);

if(cookieNameIndexOf > -1){
    var startIndexOf = cookieNameIndexOf;
    var endIndexOf = cookie.indexOf(';',startIndexOf);

    //-1일 경우 맨마지막에 위치 하므로 전체크기를 가져옴
    if(endIndexOf == -1)endIndexOf = cookie.length;
    var bbsVisitCount = new Number(cookie.substring(startIndexOf + (cookieName+'=').length, endIndexOf));
    cookie = cookieName + '=' + (++bbsVisitCount) + '; path=/; expires=' + toDay.toGMTString();
} else {
    cookie = cookieName + '=0; path=/; expires=' + toDay.toGMTString();
}

document.cookie = cookie;
```

# 적용된 스크린샷

![cookieexample](https://user-images.githubusercontent.com/6037055/43313390-e069c540-91ca-11e8-9667-151f39342103.png)

F12키를 눌러 Resources > Cookies 에서 직접 확인 할수 있습니다.

# 정리

> **자바스크립트 document.cookie 를 가져와 문자열 처리로 키=벨유 를 넣어 처리하면 되지만 저장된 쿠키의 쿠키유지시간을 가져오는방법은 모르겠음...**

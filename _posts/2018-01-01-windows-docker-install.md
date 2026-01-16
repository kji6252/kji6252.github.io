---
title: 윈도우 에서 도커(Docker)와 Kitematic 설치
layout: post
date: 2017-04-03 11:22:00
categories:
  - 도커
tags:
  - Docker

---
저같이 도커를 잘모르는 사람에게 쉽게 접근할수있게 제공해주는 GUI툴 Kitematic이 있습니다. 클릭 몇번으로 이미지를 다운로드 받아서 컨테이너 생성까지 정말 간편하게 사용하고 로그도 출력되며 웹포트가 열려있으면 웹도 쉽게 띄울수있습니다. 도커를 처음 입문 하시는 분들을 위해 설치법을 공유 합니다.

![](https://lh5.googleusercontent.com/UHmV5WSHhvRlKaAmvdguxMez7h5m-04p88NRKNJam0Djet7ruQ3J9JzjfC85aMB8bkX2Dxvhf1Vr21jal0BD_s1zERPg-cgTdozqFDqiLpnz1P4NT3xlWW_fIhkzQJsCbKKMnFEJ)

윈도우에서 도커를 깔기 위해 메인페이지의 다운로드를 사용하여 설치하였습니다.

![](https://lh6.googleusercontent.com/ebsAUwtoRySMs0YOoWc4UkepSaDRkXXmDH_XhrKDYOA8aZCj3tTLfYYBKS8UEjSovRJx5cdo1yma16UAj70T2vMegwmL-qNBthjPstKA2Ge6zoZyu25rJyfeD-G_G79AroQR2lE5)
<!-- more -->
이화면이 계속 나오고...

![](https://lh6.googleusercontent.com/2uY_SPP9eZsOy_yGU7VYxfKKp_xoxXDnkv0qPXVLdsI-jvemOY1CVwcuqHO1yaV8HUJMI8Etr3gfXHWkC5mLHOR8uo7jvVoFOp2jLKJ1yGl08zL8dMSoOP0FQOvWIFdUj5ADBSxK)

아무리 진행을 해도 안되더군요… 좌절을 하였습니다.

해결방법을 검색 하던중 어느한 커뮤니티에서 다른 페이지에 있는걸 다운 받아 설치하라고 하더군요.

![](https://lh5.googleusercontent.com/rH3s5lDU4oP-jFU4wcl8KIxxFy1dbaN3dzTbovClrNUysr3l-Ga5723b3-f2Fq-x4UkHRpotBlksGZdXOwvsqKFC3DLrw_oYVIlngTUBkC_qP0i8hh0s28h_nAji-5ZR_UPtI511)

도커 docs에 있는 다른 설치 파일을 찾았습니다. 기존껀 지우고 설치해 보죠.

[https://docs.docker.com/docker-for-windows/install/#download-docker-for-windows](https://docs.docker.com/docker-for-windows/install/#download-docker-for-windows)

여기서 잠깐!!!

Windows10 pro 이상이신 분들은 Hyper-v 를 활성화 하시는걸 추천드립니다.

윈도우10에서부터 탑재된 Hyper-v는 오라클 버추얼박스나 vm웨어보다 성능이 더 좋다고 하더군요.

![](https://lh5.googleusercontent.com/QMwKlDilT1HsrkCgEtAO7OH-oQuHY-_KuXxN88__gLzAMi7xUUto7Ye9BYvS59RJ08P5QRE5hSZ9F_PPBE4VstWZ3aO0CUW0lQCJhaRAan_KDrLhWAkAb9EXvTjRMwHzL7K5-IIq)

제어판 > 모든 제어판 항목 > 프로그램 및 기능 \> Windows 기능 > Hyper-V 체크

  
 

![](https://lh4.googleusercontent.com/vl0hPYYhVAlVXQhTs36RKv8JINMHy7hko5Lr4nSiyHMeKO6rKhNpp-LhczkKbg4PJc5VjL75VgHhiy7A55aQev1j1H6Cp4yjsU47a1-ZtUf9zmImRNqrXsEhhP3jUbCLwjV2kyW4)

![](https://lh5.googleusercontent.com/fWEe0WKHzEw3EnEK7zOZuUc6_YBAH9Iq0k_BvJYb74X_NVYkOk4Dgc78Rfl0U9enIISSPRtl-raUewQ8cau2Lcb6QGGJF-V3NGibC5nSB727PFjC0Qp8ZFs9F8Ee8WDu35LJ5fk-)

이 창이 뜨면서 작업표시줄엔 아름다운 고래 마스코트가 뜨게 됩니다.

설치후엔 PowerShell 에서 직접 도커 명령어로도 실행 할수있지만 GUI툴도 제공 함으로 같이 설치 해보겠습니다.

![](https://lh4.googleusercontent.com/JIKrsZiVQNq7OvxtICSOZZMeBeR_3mDKlx_-rqFgi_2q98QNHVnY4aYMhLz5ODwMAR889mpbl9EiePv_FGhqH6-_rw_cDCrMWWW3qVmJIKQS7pd67kndRsbifFCbSzMKZW3UxybL)

고래를 우클릭 후 Kitematic을 클릭합니다.

![](https://lh6.googleusercontent.com/jkjkJG84j11jZuWJAesHsOBYFaCnIYw0bwkitnOBUdAGMgP-rlZnu5AXp5k7D0a0wtga4h_SwIAKL-QNJSa2qAFEZqa9CDbM0RcUmL4NCBt64AGgTdY0rfZkyEKWz-ELhOQldyV5)

보시면 다운로드하고 난 뒤 압축을 푼 후 C:\\Program Files\\Docker\\Kitematic 이 디렉토리에 삽입하라는 뜻 같습니다.(압축푼 후 폴더명이 Kitematic-Windows 이므로 Kitematic으로 이름변경)

![](https://lh6.googleusercontent.com/RwQEpzbTHa9GzVn0w_Cg7tcZ3yRpHt8uNB-wb4VIBsgJAngy1DZKgJnW6Vi06rfwuPCtS2gKXmUoV6dt3QjsS43Z8HFvAFwI3MeJ8teS424NjkfdpE-uaUHRIcZ63ScMNzs-dKpy)

이 위치에 이동 한 후 다시 고래를 우클릭하여 Kitematic을 클릭 합니다.

![](https://lh6.googleusercontent.com/2ZMc0mpOOHPJadlWk9eziOCWcrcljvDclaCYtNWJmCJlnZH2zpMqEI_Ulq9jhKZhIiGXBGCcUIMXJwusQgpvfR_Lo4t18EM80koGgNtnQ-SHyJwAxgiWkCq_nM0sIz8CKQQZ00Hn)

![](https://lh6.googleusercontent.com/rUKFGuZZXE418k3te9H_vtQoyUaqrtIRZioISdWBCmMXnfECkNigSlTX2xTiuRVgHB4QcFjT09D9_iJEv3o7oGU6ljheSAF8zgigMyUAm61CG3FXbBrY17u2hA-LAzgQPtVot5Xo)

GUI로 편하게 다운로드하고 실행 할수 있습니다. 이걸로 로컬에서 텐서플로우나 젠킨스를 설치해서 연습 해보는것도 좋을거 같습니다.

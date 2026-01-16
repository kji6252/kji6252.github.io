---
title: 오브젝트 매핑과 슈퍼 타입 토큰
layout: post
date: 2017-02-26 14:49:00
categories:
  - 스프링
tags:
  - Java
  - Spring
  - JDBC

---
자바 프로젝트를 진행 하면서 외부 데이터를 가지고 VO클래스에 매핑하고 여러가지 연산작업을들 합니다. 그중에서도 VO클래스의 정보를 가져와 매핑하는 방법에 대해서 궁금하게 되었고 자바에서 제공하는 리플렉션API와 간단한 예제들을 통해서 오브젝트 매핑에 대해 알아 보겠습니다.

# 클래스 정보 가져오기

![](https://lh3.googleusercontent.com/zTxL5DggFKxHZLneUwRJK5YdQIy_LnyqIY3mBw7AfODKK8IPvXFPyKpcR_v6ubLWJNE9A0X98wRd3dh8BTzVWNiyUoW-gZ05M4u7u438Hs64zYh8oAF9agQssXweD0UXqrWDbcrO)

![](https://lh5.googleusercontent.com/7MuU11r2J8S1R1ovuTe_YtDUQUrEm6Jpw3OaMC3EXkAVFbnXa7VKuly2VVItV1R_mszHCYefqlSgCpyUB7H6KisADLcSRcBewc2eNKx7GuH7BDqhUMjKxMco3UtECaZLoFw7R-8r)

![](https://lh4.googleusercontent.com/xmWa-9ga69f3_nZPt-xnKffPO1f6QUuZ3_sHoQ9ndUWEB3S1njE5HItEUzPulcwIMbwWEAnUL498QmOUjx1MmarJLMZZ4cUbimmij0s6DNw07tjhCrRtsw7ZY4TT2ttGeS7YFoa1)

자바는 [java.lang.reflect패키지의 API](http://docs.oracle.com/javase/8/docs/api/java/lang/reflect/package-summary.html)를 가지고 클래스의 정보와 필드 어노테이션 정보까지 모두 가져 올수 있는 리플렉션을 제공 합니다.

그래서 이렇게 구할수 있는 정보를 가지고 외부에서 가져오는 json 데이터나 sql문을 가져올시 매핑을 하여서 해당 오브젝트로 값을 삽입해 넘겨줄수 있습니다.
<!-- more -->
# 조금더 편리한 API

리플렉션 API로도 훌륭하게 매핑이 가능하지만 조금더 사용하기 편리하고 안전하게 매핑할수 있도록 자바에서 제공하는 [java.beans](http://docs.oracle.com/javase/8/docs/api/java/beans/package-summary.html)  에서 제공하는 API를 사용 하겠습니다.

![](https://lh3.googleusercontent.com/8xNkymsQkfBX-TmoQ2RO0W5fdUuqgKCEfJl4R1Uawq7HBpiEK6eaEuDBZaYlkLT6dwx7PCWPg8BPAXzN6zPsTq2blXEvyfC-DWbqySgAdf2LVYaEOI4kICZTpbbx8DTKQ0crgE72)

![](https://lh6.googleusercontent.com/wPHO2g0WHhg3S21KPk2yyypIqz82MZYkd4QDRRgA533A8AyMzRnbu1cerZoq7Cy8AgVMBTvMbm83NOsz2gZCS7JRixxFxFQkGZkr2giJ-r6VyfRWvaGTrLFIr1NIAnjBtiFhc3is)

BeanInfo 객체를 생성할 땐 Introspector.getBeanInfo라는 static factory methode를 이용하여 빈정보를 생성한뒤 각각의 BeanDescriptor, PropertyDecriptors, MethodDescriptors를 가져와서 리플렉션보다는 편리하게 클래스 정보를 가져 올수 있습니다.

여기에서 map형태나 json형태의 값을 가져 왔을때 오브젝트 매핑을 해야 하는데 PropertyDecriptors의 출력결과를 자세히 보시면  각각의 property에 대해서 redeMethod와 writeMethod정보를 보여주고 있습니다. 이걸 활용하여 맵에 프로퍼티이름과 값을 넣어두고 간단하게 매핑하는 예제를 보여드리겠습니다.

# 심플 매핑

![](https://lh3.googleusercontent.com/ixgFYKAHCtiIy3oCTGPYLWDlGyzEf1Qnn5MxaiaBqV7aQi0mAUWFaWB8es5FJSEWQFlNk5p0W9owbpiF-Ed6nxzijCj2ylwkB6uuXFrYL5ft7rSEU0VKZayX1_CmNSkpAgPsNkRH)![](https://lh6.googleusercontent.com/AuVpSJA-exBvOs3jNI4zBdUAFZYHhoHbw9ejh8kmP1ZpqE3TNfW8cHn3h9flzBDpRJCkA9T7qzByUMQbXrF_XDK_HNR3mCN3_Bagpnjac3pbFhDzliPUAyzTB0xNxY3QsLmUyJ-B)

Map에 프로퍼티 이름과 동일하게 값을 셋팅해주고 List에 한개씩 담았습니다.

![](https://lh6.googleusercontent.com/lXysD5r5KMvR4KrA-4o4TzYUFbT1fY9p9L3FUGVzWbQY25OswG6QLc-57KqmhnWclxu23wBTdZfKrJNZHB-HCvKhZY2byWUeFAxX7Y3Fs-S-OKJ5oaUGkjbWINykikAoPQydIzio)

![](https://lh5.googleusercontent.com/AIAKcveEE9SqB6K814sY0cxC9z-7T1jRR2yJhPLlajwOdOEhFYqT20BG2fneRpVsMD42jdGITSU3RzEe072OhmFugCJAT_he_wG5Kl-1vIq25coVuyjWtSQh9-G1XTgSdpa-3-Fl)

소스를 보시면 셋팅된 데이터로 forEach문을 돌리면서 Map을 한개씩 가져옵니다 그러면서 데이터를 셋팅될 오브젝트를 생성하고(User u = new User();) forEach문 안에 property를 한개씩 꺼내오면서 property의 이름을 으로  Map의 키값을 검색하여 Map의 Value를 가져와 propertyDescriptor.getWriteMethod를 이용하여 값을 셋팅 해줍니다. 보기엔 복잡해 보이지만 하나씩 따라가보면 비교적 쉽게 느껴 지실수 있습니다.

  
  
 

# 타입 토큰

예제 소스 코드중에서 Introspector.getBeanInfo(User.class)가 있는데 보통 User.class를 타입 토큰 이라고 합니다. 그런데 자바에서는 아쉽게도 타입 토큰에는 컴파일시 제너릭정보를 담을수가 없어서 class정보만을 가져올수가 있습니다.(C#은 자바와는 다르게 제너릭정보를 바로 가져올 수 있다고 하네요...)

![](https://lh6.googleusercontent.com/cpaRAc9n-IR87kuFPxIG9tPazuf_MAom9eB4P28zI1UX0nB_RsLKF5TBmTEWUBXI9p77T3X0-hsxz32MewZXWc7gQqqf_oI-_HTp_zPfjIgdBTF-H_moctetQiO8AiLgqLM85E8M)

그래서 이걸 해결하기 위해 나온것이 슈퍼 타입 토큰 이라고 합니다.

# 슈퍼 타입 토큰

슈퍼 타입 토큰은 클래스의 제너릭 정보까지 가져오는 방식 입니다. 익명클래스를 작성하여 상속하면 상속된 정보는 컴파일시 지워지지가 않는다고 하여 익명클래스 상속방식으로 슈퍼 타입 토큰을 가져옵니다.

![](https://lh5.googleusercontent.com/GK_Ln1HE0_E76nWJ_iI0GosG3zu42pQlEODP_inwXj59rgHLZW9pcdD-P_jDFStl0plIjyZFM4z3SOjKb4gEotzQV3xeqr1rD7uiSq5aF2KDs4rmL4jmErWksojPAWVFbSbJearE)

![](https://lh3.googleusercontent.com/esqJ7eEkJus5ULjV1qLJS-ExMCZh0DL35V-T8MOugvu7cJ9sL41OkXaxtqKbnpfxb-rCRr1GgAr1scS-Xvp-E87_Td3hCaAQEq5roYfui3l21yXNu4Pg04Zb7HLnVZ1ToZa74Z_l)

예제 소스를 보시면 extends가 된 클래스(슈퍼 클래스)는 가져오지만 List의 String정보는 못가져오고 있습니다. 이를 이용하여 슈퍼 타입 토큰을 이용하면 제너릭 정보를 가져올수가 있습니다.

위의 예제에서 슈퍼 타입 토큰을 사용하기 편하게 클래스를 정의해 보겠습니다.

# 타입 토큰과 슈퍼 타입 토큰 비교

슈퍼 타입 토큰을 사용을 간소화 하기 위해서 클래스를 작성하였습니다.

![](https://lh5.googleusercontent.com/vvUtMfd0ahq6gexc7qxtJ_QnIF_EltH2E1DSpMwwUO4ILA0GPj3pYQj721asJI8OY2fwvreDN0NEZxdx85eLuAKvCcKH0sMJWGfCrnhgba6UUiWD81Hxrocd8F5BI2dQeOW7mq0n)

![](https://lh5.googleusercontent.com/MFcCZF1gnE9P39DXHt72O2milkUhFWw6QggdcMIwtdHl45RvsN6u5xxGwUdd8yLuZyLglwcUet0wX7pLEAtMz3CyCSk-BUxZnUbQRmd4pbwSksx4a8xpv6F9KFBhA5s0GVFH7Ggk)

ParametertizedType은 파라미터형의 타입을 표현하는 인터페이스 입니다.

  
 

![](https://lh4.googleusercontent.com/yKpVaNrNA46PntfeVXqsSRVf-235XVgOdSuq626O92BQvFMxt2ns71lh1ihPmIo36Aeo81HrDbzbQgiBDLZJOjvQa1BOC9ow1vdVcOLDr2qEiMASAiv50nqjzxyVbGaqpw2YEEJk)

![](https://lh6.googleusercontent.com/V3cwFZb8eTXCLPg2krzvc34xGM6kiheju95JdAK26g2nPSw98U_megoVlc_5pxd9tQ5DwvIfG7GROwbwBjtoPw9XAlnIs9ONsf6xdc4nh6LcnNXnhBFijuoAUYvhBLCjeXY53exq)

슈퍼 타입 토큰의 경우 제너릭정보를 모두 불러오지만 타입 토큰은 제너릭정보를 담을수가 없어 제한적일수바께 없습니다.

# 예제1\. JDBC 예제

GitHub : [https://github.com/kji6252/ORM-example2.git](https://github.com/kji6252/ORM-example2.git)

앞에서 알아본 클래스정보를 가져올수있는 BeanInfo와 슈퍼타입 토큰을 활용한 JDBC 오브젝트 매핑 예제를 작성 했습니다.

![](https://lh4.googleusercontent.com/Inrvu8Q5cyxn6uUflGwUWooTSMzcEmF836jshhhVbjiKSFL2cfiCD1xLQ3GFyf_QvIe7Jv-mtDiDCQROMhrpE7dDi5R4HZMYmGYUK3KXZxTBz6z3n1WBYw5VULSkq1-QuM1ndN3j)

그림. JDBC 예제 구성도

![](https://lh3.googleusercontent.com/5VxKu7uQT5E8aS27pza4EqO3cEaS6nfb3vl6ajm7UiQqihF97uk2xoqGjOTKvYIfC862RreaPZkClp9NvUK383apblt_jYZrVK1RolngYjfBtRo2hTFHnggWZbaxcHHMho5-EM2j)

그림. JDBC 예제 메인

![](https://lh6.googleusercontent.com/6Kl-RbXeNRpR1XoLYU-bFEn1adOyeoXO7DjVVK4m49Uc1iTEI7TB83c39KBPLsWCPNOHmMpUWwOHBYiZ_rsvN5L1Pk8j8xEnUF4R33aS98AuTyamxjkpZ3RvkidO-NeYeTR4TD8Y)

OMMaper에서는 query메서드 에서 각각 원하는 결과를 리턴 할 수 있는 classQuery,listQuery,mapQuery 로 분기 한다음 ResultSet과 BeanInfo의 PropertyDescriptor로 매핑하여 최종 결과를 리턴 하게 됩니다.

![](https://lh6.googleusercontent.com/0z2WdYBfAitNB7i_TLlnDtwosZ88xGfcxtclxh6Cl_aqO_R0Y_2BvaQx_UMS5fwXN75dbO-arWYRwxij8Jg4BvvPyntwcspZqEBToTKu5id9a0uFpCO5zf8sfnyLZczktV1jz3Sg)

# 예제2\. Spring JDBC 예제

![](https://lh5.googleusercontent.com/Rf1_7lZUrZrRZGsWz6F5j6ksmMVhOuA71twmpDXjBFX3CDKpYPyVTXmS5ZBcPRlexkF1-UnZZW809SDMaTSBQ77chQCS4zG1Yj_vRPkj3DLUn3RgeF7OG_FRw8y3RrdfcOldCfv1)

스프링에서 제공하는 SqlQuery를 상속받으면 protected abstract RowMapper<T> newRowMapper(Object\[\] parameters, Map<?, ?> context); 메서드를 구현해야 합니다.

스프링 JDBC예제에서도 예제1과 동일한 방식으로 매핑을 하였습니다.

![](https://lh3.googleusercontent.com/W_yVyNZImegA-RvhkmR4VgLkTxH27iHc668FrDQ1rVXX-Oxjj71dTnpdSWmSDe__To5p_QN55-IaxhJldjqOH_X1AVRup6-FkwhGd6MipZY8cunmBJKNccYug5JXVKILOwdvj_UU)

예제 1과 동일하게 구성 하였습니다.

![](https://lh4.googleusercontent.com/Ful9Fo8IaHCglYFUsEgmZJh1sbedNFkAdQ9GSLiGRQIxcYm8p8dQ1K0UTR_sG45GIR2nhcOQQ7_1ZOnGkUL9FcLpkBtVkESxWEHKaiFYGZs8F_dfYYZ7ao9QkutBDkCPTgockuxU)

SqlQuery에서 아이디값으로 sql문을 실행하여 RowMapper로 매핑하여 결과를 가져 옵니다.

![](https://lh6.googleusercontent.com/F82h6abhGSpL58CIuTZKNDr07P3ptcGM0hqGqj3BR4xuorELhlslqArA7mzUc_1CEnSeacflICkLipcwZ1_m45nUCXr9gzus9z9xyCXQsnQgjhUB26OMxN5NnuTLi8R3AmagW3PB)

예제 : [https://github.com/kji6252/ORM-example2](https://github.com/kji6252/ORM-example2)

# 2016_Korea_Game_Jam_1st


## 유니콩

<p align="justify">
대한민국 게임 잼에서 개발한 게임

### 게임 설명
- 게임을 플레이하는 캐릭터는 탁구공이다.
- 컨트롤러로 모터를 작동하여 탁구공의 위치를 위아래로 움직일 수 있다.
- 각 스테이지를 클리어하고 마지막 스테이지의 보스를 처치하면 된다.


<img src="/unikong.gif">

</p>


<br>

## 기술 스택

| CoronaSDK | lua |
| :--------: | :--------: |
|   <img src="https://raw.githubusercontent.com/ITJEONG-DEV/README/main/.images/coronasdk.png" width="200" height="180"/>   |   <img src="https://raw.githubusercontent.com/ITJEONG-DEV/README/main/.images/lua.png" width="180" height="180"/>    |

<br>
<br>

## 배운 점

<p align="justify">

- 웹소켓통신 사용
    - 웹소켓통신을 사용하여 캐릭터의 위치를 수신받음
    - 외부 모듈을 처음 사용해봄
</p>


## 발전한 점

<p align="justify">

- 리소스&스크립트 관리
    - 기능들을 모듈로 구현하여 스크립트 분리
    - 연관된 리소스들을 묶어서 한 번에 관리함

</p>

## 아쉬운 점
<p align="justify">

- 완성도
    - 게임 기획 확정이 늦어 실질적인 개발 시간이 부족했음.
    - 캐릭터의 움직임을 탁구공으로 변경하고, 웹소켓통신을 테스트하는 과정에서 시간을 많이 소모함.
</p>

## 후기
<p align="justify">

- 탁구공을 캐릭터로 한 간단한 슈팅 게임을 만들게 되었다. 탁구공을 움직이게 하기 위한 모터, 컨트롤러를 개발하는 파트, 탁구공의 위치를 카메라로 인식하고 이 값을 제공하는 서버 파트, 그리고 탁구공의 위치를 받아와 게임을 진행하는 파트로 나뉘어져 개발이 진행되었다. 나는 게임을 개발하게 되었다.

- 직전에 참가했던 인디게임 위크엔드에 비해서 코드를 가독성 있게 짜고, 모듈을 분리하는 등 코드를 작성하는 부분에서 많은 발전이 있었고, 처음으로 웹소켓통신이라는 외부 모듈을 사용해보게 되었다.

- 색다른 게임을 개발하는 동안 무척이나 즐거웠고, 어떻게든 결과물을 냈다는 점에서 뿌듯했다.

<img src="/ho-ong-yi.png">

</p>


<br>

## 라이센스

MIT &copy; [ITJEONG](mailto:derbana1027@gmail.com)
